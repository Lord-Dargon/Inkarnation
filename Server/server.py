import asyncio
import json
import os

from ai.ai_handler import AIHandler


TIMEOUT_SECONDS = 300
MAX_MESSAGE_LENGTH = 1024 * 16 * 16**8  # keep your original safety cap



async def read_one_message(reader: asyncio.StreamReader) -> dict | None:
    """
    Read exactly one length-prefixed message:
      [4 bytes little-endian length][payload bytes]
    Returns parsed JSON dict, or None if connection closed cleanly.
    """
    try:
        header = await reader.readexactly(4)
    except asyncio.IncompleteReadError:
        # client disconnected before we got a full header
        return None

    msg_len = int.from_bytes(header, "little")
    if msg_len < 0 or msg_len > (MAX_MESSAGE_LENGTH - 4):
        raise ValueError(f"Invalid message length: {msg_len}")

    try:
        payload = await reader.readexactly(msg_len)
    except asyncio.IncompleteReadError:
        return None

    text = payload.decode("utf-8", errors="replace")

    try:
        data = json.loads(text)
    except json.JSONDecodeError:
        # If you want to allow non-JSON messages, return {"raw": text} instead.
        raise ValueError(f"Invalid JSON payload: {text}")

    return data


class Server:
    def __init__(self, ai_handler, host: str = "0.0.0.0", port: int = 10000):
        self.host = host
        self.port = int(os.environ.get("PORT", str(port)))
        self.ai = ai_handler

    async def handle_client(self, reader: asyncio.StreamReader, writer: asyncio.StreamWriter):
        addr = writer.get_extra_info("peername")
        print(f"[CONNECT] {addr}")

        try:
            while True:
                try:
                    msg = await asyncio.wait_for(read_one_message(reader), timeout=TIMEOUT_SECONDS)
                except asyncio.TimeoutError:
                    print(f"[TIMEOUT] {addr} (no data for {TIMEOUT_SECONDS}s)")
                    break

                if msg is None:
                    print(f"[DISCONNECT] {addr}")
                    break

                print(f"[RECV] {addr}: {msg}")


                response = await self.ai.handle_msg(msg)


                message_json = (json.dumps(response) + '\n').encode()
                writer.write(message_json)
                await writer.drain()
                print(f"[SENT] {addr}: {response}")

        except (ConnectionResetError, BrokenPipeError):
            print(f"[DISCONNECT] {addr} (reset)")
        except Exception as e:
            print(f"[ERROR] {addr}: {e}")
        finally:
            try:
                writer.close()
                await writer.wait_closed()
            except Exception:
                pass

    async def start(self):
        server = await asyncio.start_server(self.handle_client, self.host, self.port)
        sockname = server.sockets[0].getsockname()
        print(f"Serving on {sockname}")

        async with server:
            await server.serve_forever()


def main():
    ai_handler = AIHandler()
    asyncio.run(Server(ai_handler).start())


if __name__ == "__main__":
    main()
