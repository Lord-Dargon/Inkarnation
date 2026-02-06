extends Node

const HOST: String = "127.0.0.1"
const PORT: int = 1234


# If disconnected attempts to reconnect at this interval
const RECONNECT_TIMEOUT: float = 3.0 
const Client_Implementation = preload("res://Scripts/client_implementation.gd")
var _client: Client_Implementation
var string_buffer: String = ""
var command_queue = []
var game_over = false

var username = "TestUser"

var player_object = null
var canvas_object = null


# Signals (occur when received a message containing information)
signal action_received(action : String, game_object : String)


# ------------------ My message functions ------------------


func send_command(image):
	var message = {
		"image": image
	}
	_client.send(message)
	
		


# ------------------ Response Received! ------------------
func _handle_client_data(data: PackedByteArray) -> void:
	#print("hcd ", data)
	string_buffer += data.get_string_from_utf8()
	var messages = string_buffer.split("\n")
	#print(messages)
	
	for i in range(messages.size() - 1):
		command_queue.append(messages[i])
	
	# Keep the remaining partial message in the buffer
	string_buffer = messages[messages.size() - 1]
	


# ------------------ Server Commands ------------------

func process_command(string_data: String) -> void:
	var dictionary = {}
	dictionary = JSON.parse_string(string_data)
	#print("Message Received:", dictionary)
	
	# Handle the message here
	var name = dictionary['name']
	var desc = dictionary['desc']
	var can_fly = dictionary['fly']
	var can_swim = dictionary['swim']
	var has_armor = dictionary['armor']
	var is_person = dictionary['person']
	var is_fire_resistant = dictionary['fire_resistant']
	var strength = dictionary['strength']
	var speed = dictionary['speed']
	var weight = dictionary['weight']
	
	print(name, can_fly, can_swim, has_armor)
	
	var tags: Array[String] = []
	if can_fly:
		tags.append("Fly")
	if can_swim:
		tags.append("Swim")
	if has_armor:
		tags.append("Armor")
	if is_person:
		tags.append("Person")
	if is_fire_resistant:
		tags.append("Fire Resistant")
	if strength >= 3:
		tags.append("Strong")
	if weight >= 3:
		tags.append("Heavy")
		
	if player_object:
		player_object.set_tags(tags)
		player_object.player_name = name
		player_object.player_speed = speed
		
		
	# Hide canvas
	if canvas_object:
		canvas_object.manual_close()



# ------------------ Base client handling functions ------------------
func _ready() -> void:
	
	#!Want to move this to the join room but had error
	
	print("Initializing Connection")
	_client = Client_Implementation.new()
	
	# Connect the signals from the client object
	_client.connected.connect(self._handle_client_connected)
	_client.disconnected.connect(self._handle_client_disconnected)
	_client.error.connect(self._handle_client_error)
	_client.data.connect(self._handle_client_data)
	add_child(_client)
	_client.connect_to_host(HOST, PORT)
	
	print("Starting listeining loop")
	while not game_over:
		await get_tree().create_timer(0.3).timeout
		
		if len(command_queue) > 0:
			print("cq", command_queue)
			process_command(command_queue.pop_front())
	
	


func _connect_after_timeout(timeout: float) -> void:
	await get_tree().create_timer(timeout).timeout
	_client.connect_to_host(HOST, PORT)


func _handle_client_connected() -> void:
	print("Client connected to server.")


func _handle_client_disconnected() -> void:
	print("Client disconnected from server.")
	_connect_after_timeout(RECONNECT_TIMEOUT) # Try to reconnect after 3 seconds

func _handle_client_error() -> void:
	print("Client error.")
	_connect_after_timeout(RECONNECT_TIMEOUT) # Try to reconnect after 3 seconds
