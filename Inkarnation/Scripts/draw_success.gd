extends Window

@onready var sprite = $Sprite2D
@onready var label = $Label


func show_self():
	
	var img := Image.new()
	img.load("res://Server/image/this_image.png")
	
	var tex := ImageTexture.create_from_image(img)
	sprite.texture = tex
	
	label.text = "You are ... " + Client.player_object.player_name
	
	show()
	

func _on_close_requested() -> void:
	hide()
