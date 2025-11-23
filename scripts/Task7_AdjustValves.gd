extends Node2D

signal task_completed(task_index: int, delta: Dictionary)

const TaskVisualHelper = preload("res://scripts/TaskVisualHelper.gd")
const UITheme = preload("res://scripts/UITheme.gd")

var task_index := 7
var success_metric := 0.0
var max_time := 10.0
var time_left := 10.0
var task_finished := false

var valve_pressures := [0.5, 0.5, 0.5]
var target_pressures := [0.6, 0.4, 0.7]
var gauge_fills = []
var target_indicators = []

func _ready():
	TaskVisualHelper.setup_task_background(self)
	TaskVisualHelper.apply_task_ui_theme(self)
	$CanvasLayer/VBoxContainer/LabelInstructions.text = "Match Pressure Gauges to Targets"
	time_left = max_time
	$Timer.start()
	
	setup_gauges()

func setup_gauges():
	# Hide old UI buttons from scene file
	if has_node("CanvasLayer/VBoxContainer/Valve1"):
		$CanvasLayer/VBoxContainer/Valve1.visible = false
	if has_node("CanvasLayer/VBoxContainer/Valve2"):
		$CanvasLayer/VBoxContainer/Valve2.visible = false
	if has_node("CanvasLayer/VBoxContainer/Valve3"):
		$CanvasLayer/VBoxContainer/Valve3.visible = false
	
	# Create 3 pressure gauges with controls
	for i in range(3):
		var x_pos = 200 + i * 300
		
		# Gauge container
		var gauge_bg = ColorRect.new()
		gauge_bg.position = Vector2(x_pos, 200)
		gauge_bg.size = Vector2(60, 300)
		gauge_bg.color = UITheme.COLOR_BG_MID
		add_child(gauge_bg)
		
		# Pressure fill
		var fill = ColorRect.new()
		fill.position = Vector2(5, 150)
		fill.size = Vector2(50, 145)
		fill.color = UITheme.COLOR_ACCENT_CYAN
		gauge_bg.add_child(fill)
		gauge_fills.append(fill)
		
		# Target indicator line
		var target_line = ColorRect.new()
		target_line.size = Vector2(60, 3)
		target_line.color = UITheme.COLOR_WARNING
		gauge_bg.add_child(target_line)
		target_indicators.append(target_line)
		
		# Control buttons
		var up_btn = Button.new()
		up_btn.text = "+"
		up_btn.position = Vector2(x_pos, 520)
		up_btn.size = Vector2(60, 40)
		UITheme.apply_theme_to_button(up_btn)
		up_btn.pressed.connect(func(): adjust_valve(i, 0.05))
		add_child(up_btn)
		
		var down_btn = Button.new()
		down_btn.text = "-"
		down_btn.position = Vector2(x_pos, 570)
		down_btn.size = Vector2(60, 40)
		UITheme.apply_theme_to_button(down_btn)
		down_btn.pressed.connect(func(): adjust_valve(i, -0.05))
		add_child(down_btn)

func start_task(index: int):
	task_index = index

func _process(_delta_time):
	$CanvasLayer/VBoxContainer/LabelTimer.text = "Time: %.0f" % time_left
	
	# Calculate average error
	var total_error := 0.0
	for i in range(valve_pressures.size()):
		total_error += abs(valve_pressures[i] - target_pressures[i])
	
	var avg_error = total_error / valve_pressures.size()
	success_metric = clamp(1.0 - (avg_error * 2.0), 0.0, 1.0)
	
	$CanvasLayer/VBoxContainer/LabelStatus.text = "Accuracy: %.1f%%" % (success_metric * 100.0)
	
	# Update gauge visuals
	for i in range(gauge_fills.size()):
		var height = valve_pressures[i] * 290.0
		gauge_fills[i].size.y = height
		gauge_fills[i].position.y = 295 - height
		
		# Color based on accuracy
		var error = abs(valve_pressures[i] - target_pressures[i])
		if error < 0.05:
			gauge_fills[i].color = UITheme.COLOR_SUCCESS
		elif error < 0.15:
			gauge_fills[i].color = UITheme.COLOR_WARNING
		else:
			gauge_fills[i].color = UITheme.COLOR_ACCENT_CYAN
		
		# Update target indicator position
		target_indicators[i].position.y = 295 - (target_pressures[i] * 290.0)

func adjust_valve(index: int, amount: float):
	if index < valve_pressures.size():
		valve_pressures[index] = clamp(valve_pressures[index] + amount, 0.0, 1.0)

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
		"stability": (success_metric - 0.5) * 0.8,
		"momentum": (success_metric - 0.5) * 0.7
	}
	
	emit_signal("task_completed", task_index, delta)
