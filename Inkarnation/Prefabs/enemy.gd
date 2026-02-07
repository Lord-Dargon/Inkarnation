extends CharacterBody2D


@export var movement_speed: float = 200.0
@export var nav_agent: NavigationAgent2D
@onready var move_check_timer: Timer = $Move_Check_Timer

func _ready() -> void:

	nav_agent.path_desired_distance = 4.0
	nav_agent.target_desired_distance = 4.0


	if not nav_agent:
		nav_agent = $NavigationAgent2D
	call_deferred("actor_setup")

func actor_setup():
	await get_tree().physics_frame


func set_movement_target():
	nav_agent.target_position = Client.player_object.global_position
	move_check_timer.start()

func _physics_process(_delta):
	if nav_agent.is_navigation_finished():
		return
	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = nav_agent.get_next_path_position()
	var new_velocity: Vector2 = current_agent_position.direction_to(next_path_position) * movement_speed
	velocity = new_velocity
	move_and_slide()
