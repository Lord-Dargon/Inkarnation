
from dataclasses import dataclass

@dataclass
class Drawing:

    name: str
    desc: str

    # Attributes
    armor: bool
    fly: bool
    swim: bool
    