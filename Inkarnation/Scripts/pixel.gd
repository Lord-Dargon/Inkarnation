extends ColorRect

func _input(event: InputEvent) -> void:
	if Input.is_action_pressed("Draw"):
		color = Color.WHITE
	if Input.is_action_pressed("Erase"):
		color = Color.BLACK
