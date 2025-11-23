extends Node2D

signal task_completed(task_index: int, delta: Dictionary)

const TaskVisualHelper = preload("res://scripts/TaskVisualHelper.gd")
const UITheme = preload("res://scripts/UITheme.gd")

var task_index := 10
var success_metric := 0.0
var max_time := 15.0
var time_left := 15.0
var task_finished := false

var alignment_angle := 0.0
var target_angle := 90.0
var beam_visual: ColorRect
var target_beam: ColorRect

func _ready():
	TaskVisualHelper.setup_task_background(self)
	TaskVisualHelper.apply_task_ui_theme(self)
	$CanvasLayer/VBoxContainer/LabelInstructions.text = "Align the Beam to Target Angle"
	
	# Disconnect scene buttons
	if has_node("CanvasLayer/VBoxContainer/HBoxContainer"):
		var hbox = $CanvasLayer/VBoxContainer/HBoxContainer
		for child in hbox.get_children():
			if child is Button:
				for connection in child.pressed.get_connections():
					child.pressed.disconnect(connection["callable"])
				child.disabled = true
		hbox.visible = false
	if has_node("CanvasLayer/VBoxContainer/HSlider"):
		$CanvasLayer/VBoxContainer/HSlider.visible = false
	
	time_left = max_time
	$Timer.start()
	
	setup_beam()

func setup_beam():
	var center = Vector2(576, 324)
	
	# Center point marker
	var center_marker = ColorRect.new()
	center_marker.position = center - Vector2(8, 8)
	center_marker.size = Vector2(16, 16)
	center_marker.color = UITheme.COLOR_TEXT
	center_marker.z_index = 10
	add_child(center_marker)
	
	# Circular guide (shows rotation range)
	var guide_circle = ColorRect.new()
	guide_circle.position = center - Vector2(180, 180)
	guide_circle.size = Vector2(360, 360)
	guide_circle.color = UITheme.COLOR_BG_MID
	guide_circle.modulate.a = 0.5
	add_child(guide_circle)
	
	# Target beam (thicker, more visible)
	target_beam = ColorRect.new()
	target_beam.position = center - Vector2(150, 10)
	target_beam.size = Vector2(300, 20)
	target_beam.pivot_offset = Vector2(150, 10)
	target_beam.color = UITheme.COLOR_WARNING
	target_beam.modulate.a = 0.4
	target_beam.rotation = deg_to_rad(target_angle)
	target_beam.z_index = 1
	add_child(target_beam)
	
	# Target angle label
	var target_label = Label.new()
	target_label.text = "TARGET: %.0f°" % target_angle
	target_label.position = Vector2(center.x - 50, 140)
	UITheme.apply_theme_to_label(target_label, 20)
	target_label.add_theme_color_override("font_color", UITheme.COLOR_WARNING)
	add_child(target_label)
	
	# Alignment beam (player-controlled, thicker)
	beam_visual = ColorRect.new()
	beam_visual.position = center - Vector2(150, 10)
	beam_visual.size = Vector2(300, 20)
	beam_visual.pivot_offset = Vector2(150, 10)
	beam_visual.color = UITheme.COLOR_ACCENT_CYAN
	beam_visual.z_index = 2
	add_child(beam_visual)
	
	# Control buttons (centered)
	var left_btn = Button.new()
	left_btn.text = "◀ ROTATE LEFT"
	left_btn.position = Vector2(350, 540)
	left_btn.size = Vector2(150, 50)
	UITheme.apply_theme_to_button(left_btn)
	left_btn.pressed.connect(_on_rotate.bind(-5.0))
	add_child(left_btn)
	
	var right_btn = Button.new()
	right_btn.text = "ROTATE RIGHT ▶"
	right_btn.position = Vector2(652, 540)
	right_btn.size = Vector2(150, 50)
	UITheme.apply_theme_to_button(right_btn)
	right_btn.pressed.connect(_on_rotate.bind(5.0))
	add_child(right_btn)

func start_task(index: int):
	task_index = index

func _process(_delta_time):
	$CanvasLayer/VBoxContainer/LabelTimer.text = "Time: %.0f" % time_left
	
	var angle_diff = abs(alignment_angle - target_angle)
	if angle_diff > 180:
		angle_diff = 360 - angle_diff
	
	success_metric = clamp(1.0 - (angle_diff / 180.0), 0.0, 1.0)
	$CanvasLayer/VBoxContainer/LabelStatus.text = "Current: %.0f° (Off by: %.1f°)" % [alignment_angle, angle_diff]
	
	# Update beam rotation
	beam_visual.rotation = deg_to_rad(alignment_angle)
	
	# Color based on accuracy
	if angle_diff < 3:
		beam_visual.color = UITheme.COLOR_SUCCESS
		$CanvasLayer/VBoxContainer/LabelStatus.add_theme_color_override("font_color", UITheme.COLOR_SUCCESS)
	elif angle_diff < 10:
		beam_visual.color = UITheme.COLOR_WARNING
		$CanvasLayer/VBoxContainer/LabelStatus.add_theme_color_override("font_color", UITheme.COLOR_WARNING)
	else:
		beam_visual.color = UITheme.COLOR_ACCENT_CYAN
		$CanvasLayer/VBoxContainer/LabelStatus.add_theme_color_override("font_color", UITheme.COLOR_ACCENT_CYAN)

func _on_rotate(degrees: float):
	alignment_angle = fmod(alignment_angle + degrees + 360.0, 360.0)

func rotate_alignment(degrees: float):
	# Keep for scene file compatibility
	_on_rotate(degrees)

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
		"order": (success_metric - 0.5) * 0.5,
		"stability": (success_metric - 0.5) * 1.0,
		"momentum": (success_metric - 0.5) * 0.4
	}
	
	emit_signal("task_completed", task_index, delta)
