extends CharacterBody2D


@export var SPEED = 200.0

@export var tags:Array[String]

func _ready() -> void:
	print(collision_mask)

func _physics_process(delta: float) -> void:
	
	if "Water" in tags:
		collision_mask = collision_mask
	
	if Input.is_action_just_pressed("Pause"):
		
		get_tree().quit()
		
	var direction = Vector2(Input.get_axis("Left", "Right"), Input.get_axis("Up", "Down")).normalized()
	if direction:
		velocity = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)

	move_and_slide()
	
