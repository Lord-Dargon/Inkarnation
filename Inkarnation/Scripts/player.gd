extends CharacterBody2D

var ink_stocks:int = 1

@export var speed_scale = 150.0
var player_name = "Player"
var player_speed = 2
@onready var move_speed = player_speed * speed_scale

@export var tags:Array[String]

@onready var player_sprite = $Sprite2D


func set_tags(tag, prev_image):
	print("New Tag ", tag)
	tags = tag
	Update_Tags()
	reload_sprite(prev_image)
	
func reload_sprite(image: Array) -> void:
	var total := image.size()
	if total == 0:
		push_warning("reload_sprite: empty image array")
		return

	var n := int(round(sqrt(float(total))))
	if n * n != total:
		push_error("reload_sprite: input size is not a perfect square")
		return

	# Convert 1D -> 2D grid
	var grid := []
	for y in range(n):
		grid.append(image.slice(y * n, (y + 1) * n))

	# Track outside false pixels
	var outside := []
	for y in range(n):
		outside.append([])
		for x in range(n):
			outside[y].append(false)

	var stack: Array[Vector2i] = []

	# Seed flood fill from edges
	for i in range(n):
		if not grid[0][i]:
			outside[0][i] = true
			stack.append(Vector2i(i, 0))
		if not grid[n - 1][i]:
			outside[n - 1][i] = true
			stack.append(Vector2i(i, n - 1))
		if not grid[i][0]:
			outside[i][0] = true
			stack.append(Vector2i(0, i))
		if not grid[i][n - 1]:
			outside[i][n - 1] = true
			stack.append(Vector2i(n - 1, i))

	# Flood fill
	while stack.size() > 0:
		var p = stack.pop_back()
		var x = p.x
		var y = p.y

		var neighbors := [
			Vector2i(x + 1, y),
			Vector2i(x - 1, y),
			Vector2i(x, y + 1),
			Vector2i(x, y - 1),
		]

		for nb in neighbors:
			if nb.x < 0 or nb.y < 0 or nb.x >= n or nb.y >= n:
				continue
			if grid[nb.y][nb.x]:
				continue
			if outside[nb.y][nb.x]:
				continue

			outside[nb.y][nb.x] = true
			stack.append(nb)

	# Create RGBA image
	var img := Image.create(n, n, false, Image.FORMAT_RGBA8)

	for y in range(n):
		for x in range(n):
			if grid[y][x]:
				img.set_pixel(x, y, Color8(255, 255, 255, 255))
			elif outside[y][x]:
				img.set_pixel(x, y, Color8(0, 0, 0, 0))
			else:
				img.set_pixel(x, y, Color8(128, 128, 128, 255))

	var tex := ImageTexture.create_from_image(img)
	Client.prev_tex = tex
	player_sprite.texture = tex

	# Pixel-art safe filtering (Godot 4)
	player_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	

func _ready() -> void:
	Client.player_object = self
	Update_Tags()

func _physics_process(delta: float) -> void:
	
	if Input.is_action_just_pressed("Pause"):
		LevelController.load_new_level("res://Scenes/main_menu.tscn")
		
	if Input.is_action_just_pressed("Restart"):
		LevelController.restart()
		
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
		
