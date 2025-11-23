extends Node2D

signal task_completed(task_index: int, delta: Dictionary)

const TaskVisualHelper = preload("res://scripts/TaskVisualHelper.gd")
const UITheme = preload("res://scripts/UITheme.gd")

var task_index := 6
var success_metric := 0.0
var max_time := 10.0
var time_left := 10.0
var task_finished := false

var beam_position := 0.0
var beam_velocity := 0.0
var target_position := 0.0
var thrust_direction := 0.0  # -1, 0, or 1

# Visual elements
var beam_visual: ColorRect
var target_line: ColorRect
var left_thrust_indicator: ColorRect
var right_thrust_indicator: ColorRect
var center_pos = Vector2(576, 324)

func _ready():
	TaskVisualHelper.setup_task_background(self)
	TaskVisualHelper.apply_task_ui_theme(self)
	$CanvasLayer/VBoxContainer/LabelInstructions.text = "Stabilize the Beam at Center"
	
	# Disconnect scene button signals
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
	beam_position = randf_range(-80.0, 80.0)  # Start closer to center
	beam_velocity = randf_range(-2.0, 2.0)  # Start with less velocity
	
	setup_beam_visual()

func setup_beam_visual():
	# Target line (center)
	target_line = ColorRect.new()
	target_line.position = center_pos - Vector2(2, 100)
	target_line.size = Vector2(4, 200)
	target_line.color = UITheme.COLOR_WARNING
	target_line.modulate.a = 0.5
	add_child(target_line)
	
	# Moving beam
	beam_visual = ColorRect.new()
	beam_visual.size = Vector2(8, 150)
	beam_visual.color = UITheme.COLOR_ACCENT_CYAN
	add_child(beam_visual)
	
	# Thrust indicators
	left_thrust_indicator = ColorRect.new()
	left_thrust_indicator.position = Vector2(300, 250)
	left_thrust_indicator.size = Vector2(40, 100)
	left_thrust_indicator.color = UITheme.COLOR_ACCENT_CYAN
	left_thrust_indicator.modulate.a = 0.0
	add_child(left_thrust_indicator)
	
	right_thrust_indicator = ColorRect.new()
	right_thrust_indicator.position = Vector2(812, 250)
	right_thrust_indicator.size = Vector2(40, 100)
	right_thrust_indicator.color = UITheme.COLOR_ACCENT_CYAN
	right_thrust_indicator.modulate.a = 0.0
	add_child(right_thrust_indicator)
	
	# Control buttons - hold to thrust
	var left_btn = Button.new()
	left_btn.text = "◄ THRUST LEFT"
	left_btn.position = Vector2(350, 550)
	left_btn.size = Vector2(150, 50)
	UITheme.apply_theme_to_button(left_btn)
	left_btn.button_down.connect(func(): thrust_direction = -1.0)
	left_btn.button_up.connect(func(): thrust_direction = 0.0)
	add_child(left_btn)
	
	var right_btn = Button.new()
	right_btn.text = "THRUST RIGHT ►"
	right_btn.position = Vector2(652, 550)
	right_btn.size = Vector2(150, 50)
	UITheme.apply_theme_to_button(right_btn)
	right_btn.button_down.connect(func(): thrust_direction = 1.0)
	right_btn.button_up.connect(func(): thrust_direction = 0.0)
	add_child(right_btn)

func start_task(index: int):
	task_index = index

func _process(_delta_time):
	$CanvasLayer/VBoxContainer/LabelTimer.text = "Time: %.0f" % time_left
	
	# Physics simulation - beam drifts with chaos
	# Add small random drift (chaotic behavior)
	beam_velocity += (randf() - 0.5) * 0.08
	
	# Apply thrust from buttons (continuous force)
	if thrust_direction != 0.0:
		beam_velocity += thrust_direction * 0.4  # Gentle continuous thrust
	
	# Apply strong damping (friction)
	beam_velocity *= 0.85
	
	# Update position
	beam_position += beam_velocity
	
	# Bounce off boundaries
	if abs(beam_position) > 200:
		beam_position = clamp(beam_position, -200, 200)
		beam_velocity *= -0.3
	
	# Update thrust indicators
	left_thrust_indicator.modulate.a = 0.7 if thrust_direction < 0 else 0.0
	right_thrust_indicator.modulate.a = 0.7 if thrust_direction > 0 else 0.0
	
	# Calculate success
	var dist = abs(beam_position - target_position)
	success_metric = clamp(1.0 - (dist / 100.0), 0.0, 1.0)
	
	$CanvasLayer/VBoxContainer/LabelStatus.text = "Stability: %.1f%%" % (success_metric * 100.0)
	
	# Update beam visual position
	beam_visual.position = center_pos + Vector2(beam_position - 4, -75)
	
	# Color based on stability
	if dist < 10:
		beam_visual.color = UITheme.COLOR_SUCCESS
	elif dist < 30:
		beam_visual.color = UITheme.COLOR_WARNING
	else:
		beam_visual.color = UITheme.COLOR_ACCENT_CYAN

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
		"stability": (success_metric - 0.5) * 1.5,
		"oscillation": (0.5 - success_metric) * 1.0
	}
	
	emit_signal("task_completed", task_index, delta)
