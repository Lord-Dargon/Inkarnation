extends Label
@onready var timer: Timer = $Timer


func _process(delta: float) -> void:
	if visible:
		visible_ratio += 0.01
		
		
	if visible_ratio >= 0.75 and timer.is_stopped():
		timer.start()
	
	


func _on_timer_timeout() -> void:
	hide()
	visible_ratio = 0
	pass # Replace with function body.
