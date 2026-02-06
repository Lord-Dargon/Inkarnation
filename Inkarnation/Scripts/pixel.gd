extends ColorRect

var active = false

@export var Foreground_Color:Color
@export var Background_Color:Color

@onready var Canvas = get_parent()

var location:Vector2

func on_mouse_enter():
	active = true

func on_mouse_exit():
	active = false



func _input(event: InputEvent) -> void:
	if active == false:
		return
	
	if Input.is_action_pressed("Draw"):
		color = Foreground_Color
		
	if Input.is_action_pressed("Erase"):
		color = Background_Color
