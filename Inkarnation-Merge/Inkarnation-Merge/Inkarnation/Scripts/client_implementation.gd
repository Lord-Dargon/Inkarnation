# Client object that handles communication to the TCP server
# From: https://www.bytesnsprites.com/posts/2021/creating-a-tcp-client-in-godot/

class_name Client_Implementation
extends Node

# Define Signals
signal connected      # Connected to server
signal data           # Received data from server
signal disconnected   # Disconnected from server
signal error          # Error with connection to server

# Setup stream connection obejct
var _status: int = 0
var _stream: StreamPeerTCP = StreamPeerTCP.new()

func _ready() -> void:
	_status = _stream.get_status()


# Connect to the server
func connect_to_host(host: String, port: int) -> void:
	print("ClientHandler Connecting to %s:%d" % [host, port])
	# Reset status so we can tell if it changes to error again.
	_status = _stream.STATUS_NONE
	var res = _stream.connect_to_host(host, port)
	print("Connect attempt:", res)
	if res != OK:
		print("Error connecting to host.")
		emit_signal("error")


# Sends a command to the server
func send(message: Dictionary) -> bool:
	
	# Add newline
	var data = JSON.stringify(message).replace('\n','')
	data += '\n'
	
	# Send message
	#print("Sending ", data)
	if _status != _stream.STATUS_CONNECTED:
		print("Error: Stream is not currently connected.", data)
		var i = 0
		var repeat_interval = 0.01
		while _status != _stream.STATUS_CONNECTED and i < 30/repeat_interval:
			await get_tree().create_timer(repeat_interval).timeout
			i += 1
	_stream.put_string(data)
	return true
	

# Function that listens for messages from the server
func _process(delta: float) -> void:
	_stream.poll()
	var new_status: int = _stream.get_status()
	if new_status != _status:
		_status = new_status
		match _status:
			_stream.STATUS_NONE:
				#print("Disconnected from host.")
				emit_signal("disconnected")
			_stream.STATUS_CONNECTING:
				#print("Connecting to host.")
				pass
			_stream.STATUS_CONNECTED:
				print("Connected to host.")
				emit_signal("connected")
			_stream.STATUS_ERROR:
				print("Error with socket stream.")
				emit_signal("error")

	if _status == _stream.STATUS_CONNECTED:
		var available_bytes: int = _stream.get_available_bytes()
		if available_bytes > 0:
			var data: Array = _stream.get_partial_data(available_bytes)
			# Check for read error.
			if data[0] != OK:
				print("Error getting data from stream: ", data[0])
				emit_signal("error")
			else:
				emit_signal("data", data[1])
