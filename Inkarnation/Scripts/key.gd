extends Area2D

func body_entered(body: Node2D) -> void:
	print("Key Key Key")
	
	LevelController.unlock()
	queue_free()
