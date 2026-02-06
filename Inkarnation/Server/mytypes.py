
from dataclasses import dataclass

@dataclass
class Drawing:

    name: str
    desc: str

    # Attributes
    armor: bool
    fly: bool
    swim: bool

    fire_resistant: bool
    strength: int
    speed: int
    weight: int
    