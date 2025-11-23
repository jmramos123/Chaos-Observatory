extends Node2D

signal task_completed(task_index: int, delta: Dictionary)

const TaskVisualHelper = preload("res://scripts/TaskVisualHelper.gd")
const UITheme = preload("res://scripts/UITheme.gd")

var task_index := 3
var success_metric := 0.0
var max_time := 10.0
var time_left := 10.0
var task_finished := false

var left_temp := 50.0
var right_temp := 50.0
var target_balance := 50.0

# Visual elements
var left_thermometer: ColorRect
var right_thermometer: ColorRect
var left_fill: ColorRect
var right_fill: ColorRect
var left_heat_button: Button
var right_heat_button: Button

func _ready():
	TaskVisualHelper.setup_task_background(self)
	TaskVisualHelper.apply_task_ui_theme(self)
	setup_visuals()
	$CanvasLayer/VBoxContainer/LabelInstructions.text = "Balance Temperature Flow"
	
	# Hide old scene buttons
	$CanvasLayer/VBoxContainer/HBoxContainer.visible = false
	
	# Start with imbalanced temperatures
	left_temp = 20.0
	right_temp = 80.0
	
	time_left = max_time
	$Timer.start()
	
	left_heat_button.pressed.connect(_on_left_pressed)
	right_heat_button.pressed.connect(_on_right_pressed)

func setup_visuals():
	# Background
	var bg = ColorRect.new()
	bg.color = UITheme.COLOR_BG_DARK
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.z_index = -1
	add_child(bg)
	
	# Create thermometer containers (centered)
	left_thermometer = ColorRect.new()
	left_thermometer.position = Vector2(400, 150)
	left_thermometer.size = Vector2(80, 350)
	left_thermometer.color = UITheme.COLOR_BG_MID
	add_child(left_thermometer)
	
	right_thermometer = ColorRect.new()
	right_thermometer.position = Vector2(672, 150)
	right_thermometer.size = Vector2(80, 350)
	right_thermometer.color = UITheme.COLOR_BG_MID
	add_child(right_thermometer)
	
	# Create temperature fills
	left_fill = ColorRect.new()
	left_fill.position = Vector2(5, 170)
	left_fill.size = Vector2(70, 175)
	left_thermometer.add_child(left_fill)
	
	right_fill = ColorRect.new()
	right_fill.position = Vector2(5, 170)
	right_fill.size = Vector2(70, 175)
	right_thermometer.add_child(right_fill)
	
	# Create heat buttons below thermometers
	left_heat_button = Button.new()
	left_heat_button.position = Vector2(370, 520)
	left_heat_button.size = Vector2(140, 50)
	left_heat_button.text = "Heat Left +"
	UITheme.apply_theme_to_button(left_heat_button)
	add_child(left_heat_button)
	
	right_heat_button = Button.new()
	right_heat_button.position = Vector2(642, 520)
	right_heat_button.size = Vector2(140, 50)
	right_heat_button.text = "Heat Right +"
	UITheme.apply_theme_to_button(right_heat_button)
	add_child(right_heat_button)
	
	# Apply UI theme
	UITheme.apply_theme_to_label($CanvasLayer/VBoxContainer/LabelInstructions, 24)
	UITheme.apply_theme_to_label($CanvasLayer/VBoxContainer/LabelTimer, 20)
	UITheme.apply_theme_to_label($CanvasLayer/VBoxContainer/LabelStatus, 18)

func start_task(index: int):
	task_index = index

func _process(_delta_time):
	$CanvasLayer/VBoxContainer/LabelTimer.text = "Time: %.0f" % time_left
	
	# Both temperatures naturally cool down at slightly different rates (chaos!)
	left_temp -= _delta_time * 7.0
	right_temp -= _delta_time * 9.0  # Right cools faster, creating imbalance
	
	# Clamp to valid range
	left_temp = clamp(left_temp, 0.0, 100.0)
	right_temp = clamp(right_temp, 0.0, 100.0)
	
	# Calculate balance - need BOTH temperatures in green zone (40-60) AND balanced
	var target_temp = 50.0
	
	# Check how close each temp is to target (50°)
	var left_deviation = abs(left_temp - target_temp)
	var right_deviation = abs(right_temp - target_temp)
	
	# Check if both are balanced (close to each other)
	var balance_diff = abs(left_temp - right_temp)
	
	# Success requires both temps near 50° AND balanced with each other
	var left_score = clamp(1.0 - (left_deviation / 50.0), 0.0, 1.0)
	var right_score = clamp(1.0 - (right_deviation / 50.0), 0.0, 1.0)
	var balance_score = clamp(1.0 - (balance_diff / 20.0), 0.0, 1.0)
	
	# Final metric is average of all three
	success_metric = (left_score + right_score + balance_score) / 3.0
	
	$CanvasLayer/VBoxContainer/LabelStatus.text = "Balance: %.1f%%" % (success_metric * 100.0)
	
	# Update thermometer visuals
	update_thermometer_visual(left_fill, left_temp)
	update_thermometer_visual(right_fill, right_temp)

func update_thermometer_visual(fill: ColorRect, temp: float):
	# Height based on temperature (0-100 range)
	var height = (temp / 100.0) * 340.0
	fill.size.y = height
	fill.position.y = 345 - height
	
	# Color gradient: blue (cold) -> cyan -> green -> yellow -> red (hot)
	if temp < 25:
		fill.color = UITheme.COLOR_ACCENT_CYAN.darkened(0.5)
	elif temp < 40:
		fill.color = UITheme.COLOR_ACCENT_CYAN
	elif temp < 60:
		fill.color = UITheme.COLOR_SUCCESS
	elif temp < 75:
		fill.color = UITheme.COLOR_WARNING
	else:
		fill.color = UITheme.COLOR_DANGER

func _on_left_pressed():
	left_temp = clamp(left_temp + 10.0, 0.0, 100.0)

func _on_right_pressed():
	right_temp = clamp(right_temp + 10.0, 0.0, 100.0)

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
		"stability": (success_metric - 0.5) * 1.0,
		"entropy": (0.5 - success_metric) * 0.8,
		"order": (success_metric - 0.5) * 0.4
	}
	
	emit_signal("task_completed", task_index, delta)
