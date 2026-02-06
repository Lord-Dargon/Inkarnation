extends CharacterBody2D

var ink_stocks:int = 1

@export var SPEED = 200.0
var player_name = "OG Name"
var player_speed = 3

@export var tags:Array[String]

@onready var player_sprite = $Sprite2D



func set_tags(tag):
	print("New Tag ", tag)
	tags = tag
	Update_Tags()
	reload_sprite()
	
func reload_sprite():
	var img := Image.new()
	img.load("res://Server/image/this_image.png")
	
	var tex := ImageTexture.create_from_image(img)
	player_sprite.texture = tex
	

func _ready() -> void:
	Client.player_object = self
	Update_Tags()

func _physics_process(delta: float) -> void:
	
	if Input.is_action_just_pressed("Pause"):
		get_tree().quit()
		
	if Input.is_action_just_pressed("Debug"):
		LevelController.unlock()
		
	var direction = Vector2(Input.get_axis("Left", "Right"), Input.get_axis("Up", "Down")).normalized()
	if direction:
		velocity = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED/5)
		velocity.y = move_toward(velocity.y, 0, SPEED/5)

	move_and_slide()

func Update_Tags():
	if "Swim" in tags:
		set_collision_mask_value(7,false)
	else:
		set_collision_mask_value(7,true)
	
	if "Fly" in tags:
		pass
	
	if "Armor" in tags:
		pass
