extends CharacterBody2D

@export_enum("Track","Path","Wander") var mode: int = 0

@export var speed_value = 3
var speed_scale = 150
var movement_speed = speed_value * speed_scale
@export var nav_agent: NavigationAgent2D

@export var path_target: Node2D

@onready var move_check_timer: Timer = $Move_Check_Timer


var path_origin

var stunned = false

func _ready() -> void:
	path_origin = global_position
	nav_agent.path_desired_distance = 4.0
	nav_agent.target_desired_distance = 4.0
	

	if not nav_agent:
		nav_agent = $NavigationAgent2D
	call_deferred("actor_setup")

func actor_setup():
	await get_tree().physics_frame

func set_movement_target():
	if mode == 1:
		nav_agent.target_position = path_target.global_position
	if mode == 0:
		nav_agent.target_position = Client.player_object.global_position
		move_check_timer.start()
	stunned = false
	

func _physics_process(_delta):
	if nav_agent.is_navigation_finished():
		if mode == 1 and nav_agent.target_position == path_target.global_position:
			nav_agent.target_position = path_origin
		elif mode == 1 and nav_agent.target_position == path_origin:
			nav_agent.target_position = path_target.global_position
		else:
			return
	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = nav_agent.get_next_path_position()
	var new_velocity: Vector2 = current_agent_position.direction_to(next_path_position).normalized() * movement_speed
	if stunned == false:
		velocity = new_velocity
	if stunned == true:
		velocity /= 1.05
	move_and_slide()


func _on_killbox_entered(body: Node2D) -> void:
	if not "Armor" in body.tags:
		LevelController.lose()
		
	if "Armor" in body.tags:
		move_check_timer.start(1)
		stunned = true
		velocity = -velocity
	pass # Replace with function body.
