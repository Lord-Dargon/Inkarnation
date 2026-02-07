extends CenterContainer

@onready var level_menu: Control = $"../Level_Menu"


func play_button_pressed() -> void:
	hide()
	level_menu.show()
	pass # Replace with function body.


func quit_button_pressed() -> void:
	get_tree().quit()
	pass # Replace with function body.


func back_button_pressed() -> void:
	show()
	level_menu.hide()
	pass # Replace with function body.
