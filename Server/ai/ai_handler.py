
from ai.tti_handler import TTIHandler
from mytypes import Drawing
from pydantic import BaseModel, Field
import asyncio
import os
import numpy as np
from PIL import Image
from dataclasses import asdict

import tools





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
if the object is capable of flight, swimming, or has armor. Also determine if the object has the following additional attrbutes:

Fire-Resistant

Strength (value from 1-5): 1 = very weak (like a bat), 2 = weak (like a mouse), 3 = moderate (like a human), 4 = strong (like a gorilla), 5 = very strong (like an elephant)

Speed (value from 1-5): 1 = very slow (like a turtle), 2 = slow (like a human), 3 = moderate (like a dog), 4 = fast (like a horse), 5 = very fast (like a cheetah)

Weight (value from 1-3): 1 = light (like a cat), 2 = moderate (like a human), 3 = heavy (like an elephant)

Living

Gives off illumination

Contains water

Machine

Can Float on Water

Is Scary

Is Cute
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
            is_person: bool = Field(
                description="Whether the object is a person"
            )
            is_fire_resistant: bool = Field(
                description="Whether the object is fire resistant"
            )
            strength: int = Field(
                description="Strength level of the object (1=very weak, 2=weak, 3=moderate, 4=strong, 5=very strong)"
            )
            speed: int = Field(
                description="Speed level of the object (1=very slow, 2=slow, 3=moderate, 4=fast, 5=very fast)"
            )
            weight: int = Field(
                description="Weight level of the object (1=light, 2=moderate, 3=heavy)"
            )
            is_living: bool = Field(
                description="Whether the object is living"
            )
            gives_off_illumination: bool = Field(
                description="Whether the object gives off illumination"
            )
            contains_water: bool = Field(
                description="Whether the object contains water"
            )
            is_machine: bool = Field(
                description="Whether the object is a machine"
            )
            can_float: bool = Field(
                description="Whether the object can float on water"
            )
            is_scary: bool = Field(
                description="Whether the object is scary"
            )
            is_cute: bool = Field(
                description="Whether the object is cute"
            )

        response = await self.tti_handler.query(prompt=prompt, structure=OutputStrucure, image_filename=image_path)
        print("------------- Response:\n",response)
    
        new_drawing = Drawing(
            name=response.get("name", "ERR"),
            desc=response.get("description", "ERR"),
            fly=response.get("can_fly", False),
            swim=response.get("can_swim", False),
            armor=response.get("has_armor", False),
            person=response.get("is_person", False),
            fire_resistant=response.get("is_fire_resistant", False),
            strength=response.get("strength", 1),
            speed=response.get("speed", 1),
            weight=response.get("weight", 1),
            living=response.get("is_living", False),
            gives_off_illumination=response.get("gives_off_illumination", False),
            contains_water=response.get("contains_water", False),
            is_machine=response.get("is_machine", False),
            can_float=response.get("can_float", False),
            is_scary=response.get("is_scary", False),
            is_cute=response.get("is_cute", False),
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

        img = tools.make_edge_black_transparent(img_np, black_value=0)
        img.save("image/this_image.png")

        game_object = await self.get_initial_drawing_object(os.path.join("image","this_image.png"))
        game_dict = asdict(game_object)

        return game_dict




if __name__ == "__main__":

    async def main():
        handler = AIHandler()

        from pathlib import Path
        folder = Path("images")

        for png_file in folder.glob("*.png"):
            print(png_file.name)   # filename.png

            print(await handler.get_initial_drawing_object(str(png_file)))


    asyncio.run(main())