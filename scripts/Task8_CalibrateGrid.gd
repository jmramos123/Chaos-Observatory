extends Node2D

signal task_completed(task_index: int, delta: Dictionary)

const TaskVisualHelper = preload("res://scripts/TaskVisualHelper.gd")
const UITheme = preload("res://scripts/UITheme.gd")

var task_index := 8
var success_metric := 0.0
var max_time := 15.0
var time_left := 15.0
var task_finished := false

# Gradient system: 0.0 = purple, 1.0 = cyan
var target_gradient := [0.0, 0.33, 0.66, 1.0]  # The gradient to match
var current_gradient := []  # Player's current gradient values
var grid_cells = []

func _ready():
	TaskVisualHelper.setup_task_background(self)
	TaskVisualHelper.apply_task_ui_theme(self)
	$CanvasLayer/VBoxContainer/LabelInstructions.text = "Match the Target Gradient"
	
	# Initialize random starting gradient for player
	for i in range(4):
		current_gradient.append(randf())
	
	# Disconnect and hide scene buttons
	for grid_name in ["Grid1", "Grid2", "Grid3", "Grid4"]:
		if has_node("CanvasLayer/VBoxContainer/" + grid_name):
			var grid = get_node("CanvasLayer/VBoxContainer/" + grid_name)
			for child in grid.get_children():
				if child is Button:
					for connection in child.pressed.get_connections():
						child.pressed.disconnect(connection["callable"])
					child.disabled = true
			grid.visible = false
	
	time_left = max_time
	$Timer.start()
	
	setup_grid()

func setup_grid():
	var center_x = 576
	
	# TARGET GRADIENT BAR (show what to match)
	var target_label = Label.new()
	target_label.text = "TARGET GRADIENT:"
	target_label.position = Vector2(center_x - 200, 120)
	UITheme.apply_theme_to_label(target_label, 20)
	target_label.add_theme_color_override("font_color", UITheme.COLOR_WARNING)
	add_child(target_label)
	
	# Show 4 target gradient cells in a row
	for i in range(4):
		var target_cell = ColorRect.new()
		target_cell.position = Vector2(center_x - 200 + i * 110, 150)
		target_cell.size = Vector2(100, 60)
		var color_value = target_gradient[i]
		target_cell.color = UITheme.COLOR_ACCENT_PURPLE.lerp(UITheme.COLOR_ACCENT_CYAN, color_value)
		add_child(target_cell)
	
	# PLAYER GRADIENT CELLS (what player adjusts)
	var player_label = Label.new()
	player_label.text = "YOUR GRADIENT:"
	player_label.position = Vector2(center_x - 200, 280)
	UITheme.apply_theme_to_label(player_label, 20)
	player_label.add_theme_color_override("font_color", UITheme.COLOR_ACCENT_CYAN)
	add_child(player_label)
	
	# Create 4 adjustable cells
	for i in range(4):
		var cell = ColorRect.new()
		cell.position = Vector2(center_x - 200 + i * 110, 310)
		cell.size = Vector2(100, 100)
		cell.color = UITheme.COLOR_ACCENT_CYAN
		add_child(cell)
		grid_cells.append(cell)
		
		# Control buttons below each cell
		var up_btn = Button.new()
		up_btn.text = "▲"
		up_btn.position = Vector2(center_x - 200 + i * 110, 420)
		up_btn.size = Vector2(45, 40)
		UITheme.apply_theme_to_button(up_btn)
		up_btn.pressed.connect(_on_adjust_gradient.bind(i, 0.1))
		add_child(up_btn)
		
		var down_btn = Button.new()
		down_btn.text = "▼"
		down_btn.position = Vector2(center_x - 200 + i * 110 + 55, 420)
		down_btn.size = Vector2(45, 40)
		UITheme.apply_theme_to_button(down_btn)
		down_btn.pressed.connect(_on_adjust_gradient.bind(i, -0.1))
		add_child(down_btn)

func start_task(index: int):
	task_index = index

func _process(_delta_time):
	$CanvasLayer/VBoxContainer/LabelTimer.text = "Time: %.0f" % time_left
	
	# Calculate how closely player gradient matches target
	var total_error := 0.0
	for i in range(4):
		var error = abs(current_gradient[i] - target_gradient[i])
		total_error += error
	
	var avg_error = total_error / 4.0
	success_metric = clamp(1.0 - (avg_error * 2.0), 0.0, 1.0)
	$CanvasLayer/VBoxContainer/LabelStatus.text = "Match: %.1f%%" % (success_metric * 100.0)
	
	# Update player cell colors to show current gradient
	for i in range(4):
		var cell = grid_cells[i]
		var color_value = current_gradient[i]
		# Gradient from purple to cyan
		cell.color = UITheme.COLOR_ACCENT_PURPLE.lerp(UITheme.COLOR_ACCENT_CYAN, color_value)
		
		# Add green tint if close to target
		var error = abs(current_gradient[i] - target_gradient[i])
		if error < 0.05:
			cell.color = cell.color.lerp(UITheme.COLOR_SUCCESS, 0.3)

func _on_adjust_gradient(index: int, amount: float):
	if index < current_gradient.size():
		current_gradient[index] = clamp(current_gradient[index] + amount, 0.0, 1.0)

func _on_adjust_harmonic(index: int, amount: float):
	# Redirect to new method
	_on_adjust_gradient(index, amount)

func adjust_harmonic(index: int, amount: float):
	# Keep for scene file compatibility
	_on_adjust_gradient(index, amount)

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
		"order": (success_metric - 0.5) * 0.7,
		"stability": (success_metric - 0.5) * 0.9,
		"oscillation": (0.5 - success_metric) * 0.5
	}
	
	emit_signal("task_completed", task_index, delta)
