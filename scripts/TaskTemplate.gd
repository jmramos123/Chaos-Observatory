extends Node2D

@onready var check = $Container/Check
@onready var text_label = $Container/Text

var task_text: String = ""
var completed: bool = false

func _ready():
	# Initialize the label
	text_label.text = task_text
	check.button_pressed = completed
	
	# Connect the checkbox update
	check.toggled.connect(_on_check_toggled)

func setup(text: String, is_completed: bool = false):
	task_text = text
	completed = is_completed
	
	if text_label:
		text_label.text = text
	if check:
		check.button_pressed = is_completed

func _on_check_toggled(value: bool):
	completed = value
