
from dataclasses import dataclass

@dataclass
class Drawing:

    name: str
    desc: str

    # Attributes
    armor: bool
    fly: bool
    swim: bool
    person: bool

    fire_resistant: bool
    strength: int
    speed: int
    weight: int

    living: bool
    gives_off_illumination: bool
    contains_water: bool
    is_machine: bool
    can_float: bool
    is_scary: bool
    is_cute: bool