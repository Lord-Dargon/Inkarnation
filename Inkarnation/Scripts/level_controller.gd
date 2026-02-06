extends Node

var ui
var goal

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Engine.time_scale = 1
	goal = get_tree().get_first_node_in_group("Goal")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	

func unlock():
	goal.activate()
	pass

func restart():
	get_tree().reload_current_scene()
	Engine.time_scale = 1

func win():
	ui.win()
	Engine.time_scale = 0
	pass
