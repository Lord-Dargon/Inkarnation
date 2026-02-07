import asyncio
import json
import os
from aiohttp import web

from ai.ai_handler import AIHandler

TIMEOUT_SECONDS = 300
MAX_MESSAGE_LENGTH = 1024 * 16 * 16**8  # keep your cap

ai = AIHandler()

routes = web.RouteTableDef()

@routes.get("/health")
async def health(_request: web.Request):
    return web.Response(text="ok")

@routes.get("/ws")
async def ws_handler(request: web.Request):
    ws = web.WebSocketResponse(heartbeat=30)
    await ws.prepare(request)

    peer = request.remote
    print(f"[WS CONNECT] {peer}")

    try:
        async for msg in ws:
            if msg.type == web.WSMsgType.TEXT:
                if len(msg.data) > MAX_MESSAGE_LENGTH:
                    await ws.send_str(json.dumps({"error": "message too large"}))
                    continue

                try:
                    data = json.loads(msg.data)
                except json.JSONDecodeError:
                    await ws.send_str(json.dumps({"error": "invalid json"}))
                    continue

                # print(f"[WS RECV] {peer}: {data}")

                try:
                    response = await asyncio.wait_for(ai.handle_msg(data), timeout=TIMEOUT_SECONDS)
                except asyncio.TimeoutError:
                    response = {"error": f"timeout after {TIMEOUT_SECONDS}s"}

                await ws.send_str(json.dumps(response))
                print(f"[WS SENT] {peer}: {response}")

            elif msg.type == web.WSMsgType.ERROR:
                print(f"[WS ERROR] {peer}: {ws.exception()}")
                break

    finally:
        print(f"[WS DISCONNECT] {peer}")

    return ws

def main():
    port = int(os.environ.get("PORT", "10000"))
    app = web.Application()
    app.add_routes(routes)
    web.run_app(app, host="0.0.0.0", port=port)

if __name__ == "__main__":
    main()
