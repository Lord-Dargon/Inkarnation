extends Window

@export var pixel_prefab: PackedScene

@onready var Canvas: GridContainer = $Canvas
@onready var draw_success = $"../DrawSuccess"
@onready var finish = $HBoxContainer/VBoxContainer2/Become

var brush_size

var array:Array[Vector2]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Client.canvas_object = self
	set_brush_medium()
	
	var img = null
	if get_tree().current_scene.name == "Level_12":
		img = Image.new()
		img.load("res://Assets/PreDrawings/circle.png")
	if get_tree().current_scene.name == "Level_13":
		img = Image.new()
		img.load("res://Assets/PreDrawings/person.png")
	if get_tree().current_scene.name == "Level_14":
		img = Image.new()
		img.load("res://Assets/PreDrawings/triangle.png")

	
	for x in Canvas.columns:
		for y in Canvas.columns:
			var p = pixel_prefab.instantiate()
			p.location = Vector2(x,y)
			
			if img:
				var color: Color = img.get_pixel(x, y)
				var value := int(color.get_luminance() * 255.0)
				if value > 100:
					p.set_stuck()
			
			Canvas.add_child(p)





func return_current_image() -> Array[bool]:
	var image: Array[bool] = []
	for pixel in Canvas.get_children():
		image.append(pixel.get_current_value() == 1)
	return image


func manual_close() -> void:
	hide()
	draw_success.show_self()
	


func _on_close_requested() -> void:
	hide()
	pass # Replace with function body.


func on_clear():
	for child in Canvas.get_children():
		if not child.stuck:
			child.color = child.Background_Color
			child.value = 0
	array.clear()
	

func _on_finish_pressed():
	
	if Client.player_object.ink_stocks >= 1:
		var image = return_current_image()
		Client.send_command(image)
		Client.player_object.ink_stocks -= 1
		
	finish.disabled = true
	finish.text = "Loading ..."
		
	
	
	
func set_brush_small():
	brush_size = 8.0
	
func set_brush_medium():
	brush_size = 16.0
	
func set_brush_large():
	brush_size = 24.0
