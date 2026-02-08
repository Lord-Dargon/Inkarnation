extends ColorRect

var active = false
var stuck = false
var value = 0

@export var Foreground_Color:Color
@export var Background_Color:Color

@onready var Canvas = get_parent()

var location:Vector2


var prev_mouse_pos: Vector2
const INTERMEDIATE_POINTS := 15

func _process(_delta):
	var mouse_pos = get_global_mouse_position()

	# First frame safety
	if prev_mouse_pos == null:
		prev_mouse_pos = mouse_pos
		return

	active = false
	var brush_size = get_parent().get_parent().brush_size

	# Check current position + 5 points in between
	for i in range(INTERMEDIATE_POINTS + 1):
		var t := float(i) / INTERMEDIATE_POINTS
		var sample_pos := prev_mouse_pos.lerp(mouse_pos, t)

		if global_position.distance_to(sample_pos) <= brush_size:
			active = true
			break

	# Remember for next frame
	prev_mouse_pos = mouse_pos





func _input(event: InputEvent) -> void:
	if active == false or stuck == true:
		return
	
	if Input.is_action_pressed("Draw"):
		color = Foreground_Color
		value = 1
		
	if Input.is_action_pressed("Erase"):
		color = Background_Color
		value = 0
		
		
func get_current_value() -> int:
	return value

	
func set_stuck():
	stuck = true
	value = 1
	color = Foreground_Color
	
	
