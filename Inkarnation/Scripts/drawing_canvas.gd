extends Window

@export var pixel_prefab: PackedScene

@onready var Canvas: GridContainer = $Canvas

var brush_size

var array:Array[Vector2]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Client.canvas_object = self
	
	for x in Canvas.columns:
		for y in Canvas.columns:
			var p = pixel_prefab.instantiate()
			p.location = Vector2(x,y)
			Canvas.add_child(p)
			
	set_brush_medium()
			
	pass # Replace with function body.
	
	
func return_current_image() -> Array[bool]:
	var image: Array[bool] = []
	for pixel in Canvas.get_children():
		image.append(pixel.get_current_value() == 1)
	return image


func _on_close_requested() -> void:
	hide()
	pass # Replace with function body.


func on_clear():
	for child in Canvas.get_children():
		child.color = child.Background_Color
		child.value = 0
	array.clear()
	

func _on_finish_pressed():
	var image = return_current_image()
	Client.send_command(image)
	
	
func set_brush_small():
	brush_size = 8.0
	
func set_brush_medium():
	brush_size = 16.0
	
func set_brush_large():
	brush_size = 24.0
