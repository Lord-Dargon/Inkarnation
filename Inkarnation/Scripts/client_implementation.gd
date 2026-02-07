# Client object that handles communication to the WebSocket server (/ws)
# Compatible with the aiohttp server I provided (expects JSON text frames).

class_name Client_Implementation
extends Node

signal connected
signal data            # Emits Dictionary by default; see below.
signal disconnected
signal error

var _ws: WebSocketPeer = WebSocketPeer.new()
var _was_connected := false

# Optional: if you want to emit raw strings instead of parsed dicts.
@export var emit_raw_text := false

func connect_to_host(host: String, port: int, use_tls: bool = true, path: String = "/ws") -> void:
	# Render: use_tls = true, host = "<service>.onrender.com", port = 443 (or pass 0)
	# Local:  use_tls = false, host = "127.0.0.1", port = 10000
	var scheme := "ws" if (host == "127.0.0.1" or host == "localhost") else "wss"

	#var url := "%s://%s:%d%s" % [scheme, host, port, path]
	var url := "%s://%s%s" % [scheme, host, path]
	

	# Some servers don't like :443 explicitly; if you want, you can omit port when 443/80.
	# For simplicity we keep it.
	print("WS Connecting to ", url)

	var err := _ws.connect_to_url(url)
	if err != OK:
		print("WebSocket connect_to_url failed: ", err)
		emit_signal("error")

func disconnect_from_host(code: int = 1000, reason: String = "") -> void:
	if _ws.get_ready_state() == WebSocketPeer.STATE_OPEN:
		_ws.close(code, reason)

func send(message: Dictionary) -> bool:
	var text := JSON.stringify(message)
	if _ws.get_ready_state() != WebSocketPeer.STATE_OPEN:
		print("Error: WebSocket is not open. Can't send: ", text)
		emit_signal("error")
		return false

	# aiohttp server expects text frames containing JSON
	var err := _ws.send_text(text)
	if err != OK:
		print("Error sending WS text: ", err)
		emit_signal("error")
		return false

	return true

func _process(_delta: float) -> void:
	_ws.poll()

	var state := _ws.get_ready_state()

	# Fire connected/disconnected transitions once
	if state == WebSocketPeer.STATE_OPEN and not _was_connected:
		_was_connected = true
		print("WS Connected")
		emit_signal("connected")

	elif (state == WebSocketPeer.STATE_CLOSED or state == WebSocketPeer.STATE_CLOSING) and _was_connected:
		_was_connected = false
		print("WS Disconnected")
		emit_signal("disconnected")

	elif state == WebSocketPeer.STATE_CONNECTING:
		pass

	# Drain incoming packets
	while _ws.get_available_packet_count() > 0:
		var pkt: PackedByteArray = _ws.get_packet()
		if _ws.get_packet_error() != OK:
			print("WS packet error: ", _ws.get_packet_error())
			emit_signal("error")
			continue

		var text := pkt.get_string_from_utf8()

		if emit_raw_text:
			emit_signal("data", text)
			continue
		var parsed: Variant = JSON.parse_string(text)

		if parsed == null:
			print("WS received non-JSON: ", text)
			emit_signal("error")
			continue

		# parsed is Variant (usually Dictionary/Array)
		print("Parsed: ", parsed)
		emit_signal("data", parsed)

	# Optional: treat STATE_CLOSED with a close code reason as an error
	# (Godot doesn't always surface close reason cleanly)
