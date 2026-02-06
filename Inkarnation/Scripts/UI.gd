extends CanvasLayer
@onready var canvas_button: Button = $Canvas_Button
@onready var drawing_canvas: Window = $"Drawing Canvas"
@onready var win_screen: CenterContainer = $Win_Screen
@onready var ink_stock_meter: HBoxContainer = $Ink_Stock_Meter


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	LevelController.ui = self
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func on_canvas_button_pressed() -> void:
	drawing_canvas.show()
	pass # Replace with function body.

func win():
	print("Won")
	drawing_canvas.hide()
	win_screen.show()

func restart_button_pressed():
	LevelController.restart()
