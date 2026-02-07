extends CharacterBody2D

var ink_stocks:int = 1

@export var speed_scale = 150.0
var player_name = "Player"
var player_speed = 2
@onready var move_speed = player_speed * speed_scale

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
		LevelController.load_new_level("res://Scenes/main_menu.tscn")
		
	if Input.is_action_just_pressed("Restart"):
		LevelController.restart()
		
	if Input.is_action_just_pressed("Debug"):
		LevelController.unlock()
		
	var direction = Vector2(Input.get_axis("Left", "Right"), Input.get_axis("Up", "Down")).normalized()
	if direction:
		velocity = direction * move_speed
		if direction.x < 0:
			player_sprite.flip_h = true
		elif direction.x > 0:
			player_sprite.flip_h = false
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed/5)
		velocity.y = move_toward(velocity.y, 0, move_speed/5)

	move_and_slide()



func Update_Tags():
	move_speed = speed_scale * player_speed
	
	
	if "Swim" in tags:
		set_collision_mask_value(7,false)
	else:
		set_collision_mask_value(7,true)
	
	if "Fly" in tags:
		set_collision_mask_value(6,false)
	else:
		set_collision_mask_value(6,true)
	
	if "Armor" in tags:
		pass
		
	if "Strong" in tags:
		set_collision_mask_value(5,false)
		set_collision_layer_value(5, true)
	else:
		set_collision_mask_value(5,true)
		set_collision_layer_value(5, false)
		
