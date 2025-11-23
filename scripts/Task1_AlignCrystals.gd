extends Node2D

signal task_completed(task_index: int, delta: Dictionary)

const TaskVisualHelper = preload("res://scripts/TaskVisualHelper.gd")
const UITheme = preload("res://scripts/UITheme.gd")

var task_index := 1
var success_metric := 0.0
var max_time := 10.0
var time_left := 10.0

@onready var crystal := $Crystal
@onready var target := $Target

func _ready():
	TaskVisualHelper.setup_task_background(self)
	TaskVisualHelper.apply_task_ui_theme(self)
	setup_visuals()
	$CanvasLayer/VBoxContainer/LabelInstructions.text = "Align the Crystal!"
	time_left = max_time
	$Timer.start()

	# Make crystal draggable
	crystal.process_mode = Node.PROCESS_MODE_ALWAYS
	set_process_input(true)

func setup_visuals():
	# Center the target on screen (existing scene node)
	var center = Vector2(576, 324)
	target.position = center - Vector2(40, 40)  # Center the 80x80 target
	target.color = UITheme.COLOR_ACCENT_PURPLE.darkened(0.3)
	target.size = Vector2(80, 80)
	target.rotation = 0  # Square
	
	# Position crystal randomly but visible (existing scene node)
	crystal.position = Vector2(randf() * 800 + 176, randf() * 400 + 124)
	crystal.color = UITheme.COLOR_ACCENT_CYAN
	crystal.size = Vector2(50, 50)
	crystal.rotation = deg_to_rad(45)  # Diamond shape
	
	# Apply UI theme
	var instructions = $CanvasLayer/VBoxContainer/LabelInstructions
	UITheme.apply_theme_to_label(instructions, 24)
	instructions.add_theme_color_override("font_color", UITheme.COLOR_ACCENT_CYAN)
	
	var timer_label = $CanvasLayer/VBoxContainer/LabelTimer
	UITheme.apply_theme_to_label(timer_label, 20)
	
	# Background
	var bg = ColorRect.new()
	bg.color = UITheme.COLOR_BG_DARK
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.z_index = -1
	add_child(bg)


func start_task(index: int):
	task_index = index


func _process(_delta_time):
	$CanvasLayer/VBoxContainer/LabelTimer.text = "Time: %.0f" % time_left

	# Compute success every frame (center to center distance)
	var crystal_center = crystal.position + Vector2(25, 25)  # 50x50 crystal
	var target_center = target.position + Vector2(40, 40)    # 80x80 target
	var dist = crystal_center.distance_to(target_center)
	var max_dist = 400.0
	success_metric = clamp(1.0 - (dist / max_dist), 0.0, 1.0)
	
	# Visual feedback - crystal glows more when aligned
	if success_metric > 0.9:
		crystal.color = UITheme.COLOR_SUCCESS
	elif success_metric > 0.7:
		crystal.color = UITheme.COLOR_WARNING
	else:
		crystal.color = UITheme.COLOR_ACCENT_CYAN
	
	crystal.modulate = Color(1, 1, 1, 0.6 + success_metric * 0.4)
	
	# Target pulses
	var pulse = 1.0 + sin(Time.get_ticks_msec() * 0.003) * 0.15
	target.scale = Vector2.ONE * pulse


func _on_Timer_timeout():
	time_left -= 1.0
	if time_left <= 0:
		$Timer.stop()
		finish_task()
	else:
		$Timer.start()


func _input(event):
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		crystal.global_position = event.position


var task_finished := false

func finish_task():
	if task_finished:
		return
	task_finished = true
	
	var delta := {
		"order": (success_metric - 0.5) * 0.8,
		"stability": (success_metric - 0.5) * 0.5,
		"entropy": (0.5 - success_metric) * 0.4
	}

	emit_signal("task_completed", task_index, delta)
