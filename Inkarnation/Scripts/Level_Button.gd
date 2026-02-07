extends Button

@export var level: int = 1

func _ready() -> void:
	text = str(level)

func _on_pressed() -> void:
	LevelController.load_new_level("res://Scenes/level_" + str(level) + ".tscn")
	pass # Replace with function body.
