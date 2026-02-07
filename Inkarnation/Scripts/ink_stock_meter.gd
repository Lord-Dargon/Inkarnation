extends HBoxContainer

@onready var fill: TextureRect = $Ink_Ind_1/Fill
@onready var fill_2: TextureRect = $Ink_Ind_2/Fill2
@onready var fill_3: TextureRect = $Ink_Ind_3/Fill3
@onready var canvas_button = $"../Canvas_Button"




var stocks:int = 0

func _process(delta: float) -> void:
	if stocks <= 0:
		fill.hide()
		fill.hide()
		fill.hide()
		canvas_button.disabled = true
	if stocks > 0:
		canvas_button.disabled = false
		fill.show()
		fill_2.hide()
	if stocks > 1:
		fill_2.show()
		fill_3.hide()
	if stocks > 2:
		fill_3.show()
		
	stocks = Client.player_object.ink_stocks
