extends Label


func _process(delta: float) -> void:
	if visible:
		visible_ratio += 0.01
