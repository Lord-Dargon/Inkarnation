extends Window

@onready var sprite = $Sprite2D
@onready var label = $Label


func show_self():
	sprite.texture = Client.prev_tex
	
	label.text = "You are ... " + Client.player_object.player_name
	
	show()
	

func _on_close_requested() -> void:
	hide()
	
func _on_button_pressed():
	hide()
