extends CharacterBody2D


@export var SPEED = 200.0

@export var tags:Array[String]

func _ready() -> void:
	Update_Tags()

func _physics_process(delta: float) -> void:
	
	if Input.is_action_just_pressed("Pause"):
		get_tree().quit()
		
	var direction = Vector2(Input.get_axis("Left", "Right"), Input.get_axis("Up", "Down")).normalized()
	if direction:
		velocity = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED/5)
		velocity.y = move_toward(velocity.y, 0, SPEED/5)

	move_and_slide()

func Update_Tags():
	if "Swim" in tags:
		set_collision_mask_value(7,false)
	else:
		set_collision_mask_value(7,true)
	
	if "Fly" in tags:
		pass
	
	if "Armor" in tags:
		pass
