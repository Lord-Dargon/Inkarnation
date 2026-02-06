extends ColorRect

var active = false
var value = 0

@export var Foreground_Color:Color
@export var Background_Color:Color

@onready var Canvas = get_parent()

var location:Vector2


func _process(_delta):
	var mouse_pos = get_global_mouse_position()
	var dist = global_position.distance_to(mouse_pos)

	active = dist <= get_parent().get_parent().brush_size



func _input(event: InputEvent) -> void:
	if active == false:
		return
	
	if Input.is_action_pressed("Draw"):
		color = Foreground_Color
		value = 1
		
	if Input.is_action_pressed("Erase"):
		color = Background_Color
		value = 0
		
		
func get_current_value() -> int:
	return value
	
	
