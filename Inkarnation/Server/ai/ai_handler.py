
from ai.tti_handler import TTIHandler
from mytypes import Drawing
from pydantic import BaseModel, Field
import asyncio
import os
import numpy as np
from PIL import Image
from dataclasses import asdict


class AIHandler:
    """
    Class for handling all AI interactions, including TTI and future capabilities.
    """

    def __init__(self):
        self.tti_handler = TTIHandler()
        self.max_tries = 3


    async def get_initial_drawing_object(self, image_path: str) -> Drawing:
        """
        Uses TTI to get an initial drawing object from an image.
        """

        prompt = f"""
The following is a sketch of something. Give the name of the object, a 3 sentence description of the phsyical traits the object has, and determine 
if the object is capable of flight, swimming, or has armor.
"""
        
        class OutputStrucure(BaseModel):
            name: str = Field(
                description="Name of the object depicted in the sketch"
            )
            description: str = Field(
                description="A 3 sentence description of the physical traits of the object depicted in the sketch"
            )
            can_fly: bool = Field(
                description="Whether the object is capable of flight"
            )
            can_swim: bool = Field(
                description="Whether the object is capable of swimming"
            )
            has_armor: bool = Field(
                description="Whether the object has armor"
            )

        response = await self.tti_handler.query(prompt=prompt, structure=OutputStrucure, image_filename=image_path)
        print("------------- Response:\n",response)
    
        new_drawing = Drawing(
            name=response.get("name", "ERR"),
            desc=response.get("description", "ERR"),
            fly=response.get("can_fly", False),
            swim=response.get("can_swim", False),
            armor=response.get("has_armor", False)
        )

        return new_drawing
    


    async def handle_msg(self, msg: dict) -> dict:
        print("-------- Received dict:\n", msg)

        image = msg.get("image")  # expected: 2D array

        if image is None:
            raise ValueError("No image found in message")

        # Convert to numpy array (in case it's a list of lists)
        img_np = np.asarray(image)

        if img_np.ndim != 2:
            M = int(img_np.shape[0]**0.5)
            img_np = img_np.reshape((M,M))  # reshape to 2D

        # Normalize if needed (e.g. floats in [0,1])
        if img_np.dtype != np.uint8:
            img_np = img_np.astype(np.float32)
            img_np = (255 * (img_np - img_np.min()) / (np.ptp(img_np) + 1e-8)).astype(np.uint8)

        os.makedirs("image", exist_ok=True)

        img = Image.fromarray(img_np, mode="L")  # L = grayscale
        img.save("image/this_image.png")

        game_object = await self.get_initial_drawing_object("image/this_image.png")
        game_dict = asdict(game_object)

        return game_dict




if __name__ == "__main__":

    async def main():
        handler = AIHandler()

        # ---------------------------
        # TEST: 2D array image path
        # ---------------------------

        # Option A: float image (forces normalization branch)
        h, w = 128, 128
        y, x = np.mgrid[0:h, 0:w]
        img2d_float = (np.sin(x / 10.0) + np.cos(y / 13.0))  # values roughly in [-2, 2]
        msg = {"image": img2d_float.tolist()}  # simulate JSON payload (list of lists)

        # Option B: uint8 image (skip normalization branch)
        # img2d_u8 = (np.random.rand(h, w) * 255).astype(np.uint8)
        # msg = {"image": img2d_u8.tolist()}

        result = await handler.handle_msg(msg)

        # Verify the file got saved
        saved_path = "image/this_image.png"
        if not os.path.exists(saved_path):
            raise RuntimeError(f"Test failed: {saved_path} was not created")

        print("✅ Saved:", saved_path)
        print("✅ Returned dict:\n", result)

        # Optional: quick sanity check that it loads as an image
        im = Image.open(saved_path)
        print("✅ Loaded saved image mode/size:", im.mode, im.size)

    asyncio.run(main())