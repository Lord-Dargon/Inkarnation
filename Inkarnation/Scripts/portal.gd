extends Area2D

@export var destination_x: int
@export var destination_y: int
@export var criteria: String = "None"
@export var backup_x: int
@export var backup_y: int
@export var portal_name: String

@onready var title = $Title


func _ready():
	title.text = portal_name


func _on_body_entered(body):
	
	var condition_met = false
	
	if criteria in body.tags:
		condition_met = true
	

	if condition_met:
		body.position.x = destination_x
		body.position.y = destination_y
	else:
		body.position.x = backup_x
		body.position.y = backup_y
