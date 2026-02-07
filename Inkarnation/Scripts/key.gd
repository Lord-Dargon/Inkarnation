extends Area2D

func body_entered(body: Node2D) -> void:
	print("Key Key Key")
	
	LevelController.unlock()
	await get_tree().process_frame
	queue_free()
