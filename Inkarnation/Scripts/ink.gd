extends Area2D

@onready var liquid: Sprite2D = $Liquid

func _process(delta: float) -> void:
	liquid.self_modulate.h += 0.001
	if liquid.self_modulate.h >= 1:
		liquid.self_modulate.h = 0

func body_entered(body: Node2D) -> void:
	print("Glug Glug Glug")
	
	body.ink_stocks += 1
	queue_free()
	pass # Replace with function body.
