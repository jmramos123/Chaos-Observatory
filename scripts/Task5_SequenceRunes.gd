extends Node2D

signal task_completed(task_index: int, delta: Dictionary)

const TaskVisualHelper = preload("res://scripts/TaskVisualHelper.gd")
const UITheme = preload("res://scripts/UITheme.gd")

var task_index := 5
var success_metric := 0.0
var max_time := 15.0
var time_left := 15.0
var task_finished := false

var sequence := []
var current_input := []
var max_length := 6
var rune_buttons = []
var reset_button: Button

func _ready():
	TaskVisualHelper.setup_task_background(self)
	TaskVisualHelper.apply_task_ui_theme(self)
	
	# Generate random sequence
	sequence = [1, 2, 3, 4, 5, 6]
	sequence.shuffle()
	
	# Update instructions to show the target sequence
	var seq_str = ""
	for i in range(sequence.size()):
		seq_str += str(sequence[i])
		if i < sequence.size() - 1:
			seq_str += "→"
	$CanvasLayer/VBoxContainer/LabelInstructions.text = "Click Runes in Order: " + seq_str
	
	# Hide old scene buttons and disconnect their signals
	if has_node("CanvasLayer/VBoxContainer/HBoxContainer"):
		var hbox = $CanvasLayer/VBoxContainer/HBoxContainer
		for child in hbox.get_children():
			if child is Button:
				for connection in child.pressed.get_connections():
					child.pressed.disconnect(connection["callable"])
				child.disabled = true
		hbox.visible = false
	
	time_left = max_time
	$Timer.start()
	
	setup_runes()

func setup_runes():
	# Create visual runes in a centered grid pattern
	var center_x = 576  # Screen center
	var center_y = 324
	var positions = [
		Vector2(center_x - 250, center_y - 100),  # Rune 1 - top left
		Vector2(center_x + 170, center_y - 100),  # Rune 2 - top right
		Vector2(center_x - 250, center_y + 100),  # Rune 3 - bottom left
		Vector2(center_x + 170, center_y + 100),  # Rune 4 - bottom right
		Vector2(center_x - 40, center_y - 100),   # Rune 5 - top center
		Vector2(center_x - 40, center_y + 100)    # Rune 6 - bottom center
	]
	
	for i in range(6):
		var rune_num = i + 1
		var button = Button.new()
		button.text = str(rune_num)
		button.position = positions[i]
		button.size = Vector2(80, 80)
		button.z_index = 100  # Above everything including CanvasLayer
		UITheme.apply_theme_to_button(button)
		button.add_theme_font_size_override("font_size", 32)
		# Fix: Use Callable.bind() to properly capture the value
		button.pressed.connect(_on_rune_pressed.bind(rune_num))
		add_child(button)
		rune_buttons.append(button)
	
	# Reset button (centered at bottom)
	reset_button = Button.new()
	reset_button.text = "RESET"
	reset_button.position = Vector2(501, 520)
	reset_button.size = Vector2(150, 50)
	reset_button.z_index = 100  # Above everything
	UITheme.apply_theme_to_button(reset_button)
	reset_button.pressed.connect(_on_reset_pressed)
	add_child(reset_button)

func start_task(index: int):
	task_index = index

func _process(_delta_time):
	$CanvasLayer/VBoxContainer/LabelTimer.text = "Time: %.0f" % time_left
	
	# Calculate correctness
	var correct := 0
	for i in range(min(current_input.size(), sequence.size())):
		if current_input[i] == sequence[i]:
			correct += 1
		else:
			break  # Stop counting if sequence breaks
	
	success_metric = float(correct) / float(sequence.size())
	
	# Show current sequence
	var seq_str = ""
	for num in current_input:
		seq_str += str(num) + " "
	$CanvasLayer/VBoxContainer/LabelStatus.text = "Input: " + seq_str
	
	# Visual feedback - highlight buttons based on whether they've been clicked correctly
	for i in range(rune_buttons.size()):
		var rune_value = i + 1
		# Check if this rune appears in current_input at the correct position in sequence
		if current_input.has(rune_value):
			var input_index = current_input.find(rune_value)
			if input_index < sequence.size() and sequence[input_index] == rune_value:
				rune_buttons[i].modulate = UITheme.COLOR_SUCCESS
			else:
				rune_buttons[i].modulate = UITheme.COLOR_DANGER
		else:
			rune_buttons[i].modulate = Color.WHITE

func _on_rune_pressed(num: int):
	if current_input.size() < max_length:
		current_input.append(num)

func _on_reset_pressed():
	current_input.clear()

func add_rune(num: int):
	# Keep for compatibility with scene file buttons (if any)
	if current_input.size() < max_length:
		current_input.append(num)

func _on_Timer_timeout():
	time_left -= 1.0
	if time_left <= 0:
		$Timer.stop()
		finish_task()
	else:
		$Timer.start()

func finish_task():
	if task_finished:
		return
	task_finished = true
	
	var delta := {
		"order": (success_metric - 0.5) * 1.0,
		"stability": (success_metric - 0.5) * 0.6
	}
	
	emit_signal("task_completed", task_index, delta)
