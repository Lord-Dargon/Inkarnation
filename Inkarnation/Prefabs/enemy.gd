extends CharacterBody2D

const SPEED := 300

func _physics_process(delta):
	var player = Client.player_object
	if not player:
		return

	var direction = (player.global_position - global_position).normalized()
	velocity = direction * SPEED
	move_and_slide()



func _on_area_2d_body_entered(body):
	print("Die Die Die")
	LevelController.lose()
	queue_free()
