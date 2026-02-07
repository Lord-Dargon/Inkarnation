extends Area2D

@export var active: bool = false
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	if active == false:
		modulate.a = 0.4
		collision_shape_2d.disabled = true


func activate():
	modulate.a = 1
	collision_shape_2d.disabled = false


func body_entered(body: Node2D) -> void:
	LevelController.win()
	pass # Replace with function body.
