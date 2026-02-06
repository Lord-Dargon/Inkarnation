import os
import json
import random
import asyncio
import base64
import mimetypes
from typing import Type, Optional

from dotenv import load_dotenv
from pydantic import BaseModel, Field
import aiohttp


class TTIHandler:
    """
    Interface with openrouter, which has several LLMs from different services.
    Adds:
      - request timeout (configurable in __init__)
      - retries with exponential backoff + jitter on timeout or network/server errors
      - OPTIONAL image attachment (local file -> base64 data URL) in messages content
    """



    def __init__(
        self,
        provider: str = "google",
        model: str = "gemini-2.5-flash",
        *,
        timeout_seconds: float = 5.0,
        max_retries: int = 3,
        backoff_base_seconds: float = 0.5,
        backoff_max_seconds: float = 8.0,
    ):
        load_dotenv()

        self.url: str = "https://openrouter.ai/api/v1/chat/completions"
        self.api_key = os.getenv("OPENROUTER_KEY")
        self.provider: str = provider
        self.model: str = model

        self.timeout_seconds = float(timeout_seconds)
        self.max_retries = int(max_retries)
        self.backoff_base = float(backoff_base_seconds)
        self.backoff_max = float(backoff_max_seconds)

        self.requests_made = 0

        if not self.api_key:
            print("Warning: OPENROUTER_KEY is not set.")

    async def _sleep_with_jitter(self, attempt: int) -> None:
        base = min(self.backoff_max, self.backoff_base * (2 ** (attempt - 1)))
        delay = random.uniform(base * 0.5, base)
        await asyncio.sleep(delay)

    def _image_file_to_data_url(self, image_filename: str) -> str:
        """
        Load a local image file and convert it to a data URL:
          data:<mime>;base64,<...>
        """
        if not os.path.isfile(image_filename):
            raise FileNotFoundError(f"Image file not found: {image_filename}")

        mime, _ = mimetypes.guess_type(image_filename)
        if not mime:
            # reasonable default if extension is unknown
            mime = "image/png"

        with open(image_filename, "rb") as f:
            b64 = base64.b64encode(f.read()).decode("utf-8")

        return f"data:{mime};base64,{b64}"

    async def _post_with_retries(self, session: aiohttp.ClientSession, payload: dict) -> dict:
        attempts = self.max_retries + 1
        last_err: Optional[Exception] = None

        for attempt in range(1, attempts + 1):
            try:
                timeout = aiohttp.ClientTimeout(total=self.timeout_seconds)
                async with session.post(
                    url=self.url,
                    headers={
                        "Authorization": f"Bearer {self.api_key}",
                        "Content-Type": "application/json",
                    },
                    data=json.dumps(payload),
                    timeout=timeout,
                ) as response:
                    if response.status >= 400:
                        body_text = await response.text()
                        raise aiohttp.ClientResponseError(
                            request_info=response.request_info,
                            history=response.history,
                            status=response.status,
                            message=f"HTTP {response.status}: {body_text[:500]}",
                            headers=response.headers,
                        )

                    data = await response.json(content_type=None)
                    return data

            except (asyncio.TimeoutError, aiohttp.ClientError, json.JSONDecodeError) as e:
                last_err = e
                if attempt < attempts:
                    await self._sleep_with_jitter(attempt)
                else:
                    break

        print(f"Request failed after {attempts} attempts (timeout={self.timeout_seconds}s): {last_err}")
        return {}

    async def query(
        self,
        prompt: str,
        structure: Optional[Type[BaseModel]] = None,
        *,
        image_filename: Optional[str] = None,
    ) -> dict:
        # Tunables
        top_p = 1
        temperature = 0.7
        frequency_penalty = 0
        presence_penalty = 0
        repetition_penalty = 0
        top_k = 0

        # Build the user message.
        # If image_filename is provided, send multimodal content array (text + image_url).
        if image_filename:
            try:
                data_url = self._image_file_to_data_url(image_filename)
            except Exception as e:
                print(f"Warning: could not attach image '{image_filename}': {e}")
                data_url = None

            if data_url:
                user_content = [
                    {"type": "text", "text": prompt},
                    {"type": "image_url", "image_url": {"url": data_url}},
                ]
            else:
                user_content = prompt
        else:
            user_content = prompt

        messages = [
            {"role": "user", "content": user_content},
        ]

        structure_dict = {"response": "put text here"}
        if structure is not None:
            structure_dict = structure.model_json_schema()

        payload = {
            "model": f"{self.provider}/{self.model}",
            "messages": messages,
            "top_p": top_p,
            "temperature": temperature,
            "frequency_penalty": frequency_penalty,
            "presence_penalty": presence_penalty,
            "repetition_penalty": repetition_penalty,
            "top_k": top_k,
            "response_format": {
                "type": "json_schema",
                "json_schema": {
                    "name": "item_combination",
                    "strict": True,
                    "schema": structure_dict,
                },
            },
        }

        async with aiohttp.ClientSession() as session:
            data = await self._post_with_retries(session, payload)


        choices = data.get("choices") or []
        if not choices or not isinstance(choices, list):
            raise KeyError("No choices returned")

        first = choices[0]
        message = first.get("message") if isinstance(first, dict) else None
        content = message.get("content") if isinstance(message, dict) else None
        if not content or not isinstance(content, str):
            raise KeyError("Could not find choices[0].message.content")

        return json.loads(content)







if __name__ == "__main__":
    handler = TTIHandler(timeout_seconds=20, max_retries=2)

    # class OutputStrucure(BaseModel):
    #     reason: str = Field(description="Brief explanation behind why resulting item is the combination.")
    #     result_element: str = Field(description="The name of the resulting item")

    async def main():
        # Text-only
        # r1 = await handler.query(
        #     ("Combine the following items:", "Fire and Air"),
        #     structure=OutputStrucure,
        # )
        # print("Text-only:", r1)

        class OutputStrucure(BaseModel):
            name: str = Field(description="Name of the object depicted in the sketch")
            description: str = Field(description="A 3 sentence description of the physical traits of the object depicted in the sketch")
            can_fly: bool = Field(description="Whether the object is capable of flight")

        # Text + image (local filename)
        r2 = await handler.query(
            "This is an image of a sketch. Give the name of the object portreyed, and determine if the object is capable of flight.",
            structure=OutputStrucure,  # vision prompts usually aren't strict JSON unless you want it
            image_filename="images/b.png",
        )
        print("With image:", r2)

    asyncio.run(main())
