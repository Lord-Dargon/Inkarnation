extends HBoxContainer

@onready var fill: TextureRect = $Ink_Ind_1/Fill
@onready var fill_2: TextureRect = $Ink_Ind_2/Fill2
@onready var fill_3: TextureRect = $Ink_Ind_3/Fill3




var stocks:int = 0

func _process(delta: float) -> void:
	if stocks > 0:
		fill.show()
	if stocks > 1:
		fill_2.show()
	if stocks > 2:
		fill_3.show()
		
	stocks = Client.player_object.ink_stocks
