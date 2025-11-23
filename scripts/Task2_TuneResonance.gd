extends Node2D

signal task_completed(task_index: int, delta: Dictionary)

const TaskVisualHelper = preload("res://scripts/TaskVisualHelper.gd")
const UITheme = preload("res://scripts/UITheme.gd")

var task_index := 2
var success_metric := 0.0
var max_time := 12.0
var time_left := 12.0
var task_finished := false

var target_frequency := 0.5
var current_frequency := 0.5

# Visual elements
var target_indicator: ColorRect
var current_indicator: ColorRect
var frequency_bars := []

@onready var slider = $CanvasLayer/VBoxContainer/HSlider

func _ready():
	TaskVisualHelper.setup_task_background(self)
	TaskVisualHelper.apply_task_ui_theme(self)
	setup_visuals()
	$CanvasLayer/VBoxContainer/LabelInstructions.text = "Match the Target Frequency (Purple Line)"
	time_left = max_time
	$Timer.start()
	
	# Randomize target based on deterministic seed
	target_frequency = 0.25 + (hash(Time.get_ticks_msec()) % 100) / 100.0 * 0.5
	
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.value = 0.5
	slider.value_changed.connect(_on_slider_changed)
	
	# Initial calculation
	_on_slider_changed(0.5)

func setup_visuals():
	# Background
	var bg = ColorRect.new()
	bg.color = UITheme.COLOR_BG_DARK
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.z_index = -1
	add_child(bg)
	
	# Create oscilloscope display area
	var scope_bg = ColorRect.new()
	scope_bg.position = Vector2(200, 150)
	scope_bg.size = Vector2(752, 300)
	scope_bg.color = Color(0.05, 0.05, 0.1, 1.0)
	add_child(scope_bg)
	
	# Create frequency bars (visual spectrum analyzer)
	for i in range(10):
		var bar = ColorRect.new()
		bar.position = Vector2(220 + i * 72, 500)
		bar.size = Vector2(50, 10)
		bar.color = UITheme.COLOR_ACCENT_CYAN.darkened(0.5)
		add_child(bar)
		frequency_bars.append(bar)
	
	# Target frequency indicator (where player needs to be)
	target_indicator = ColorRect.new()
	target_indicator.size = Vector2(6, 300)
	target_indicator.color = UITheme.COLOR_ACCENT_PURPLE
	target_indicator.modulate.a = 0.8
	add_child(target_indicator)
	
	# Current frequency indicator (where player currently is)
	current_indicator = ColorRect.new()
	current_indicator.size = Vector2(6, 300)
	current_indicator.color = UITheme.COLOR_ACCENT_CYAN
	add_child(current_indicator)
	
	# Apply UI theme
	UITheme.apply_theme_to_label($CanvasLayer/VBoxContainer/LabelInstructions, 20)
	UITheme.apply_theme_to_label($CanvasLayer/VBoxContainer/LabelTimer, 20)
	UITheme.apply_theme_to_label($CanvasLayer/VBoxContainer/LabelStatus, 24)
	$CanvasLayer/VBoxContainer/LabelStatus.add_theme_color_override("font_color", UITheme.COLOR_ACCENT_CYAN)

func start_task(index: int):
	task_index = index

func _process(_delta_time):
	$CanvasLayer/VBoxContainer/LabelTimer.text = "Time: %.0f" % time_left
	
	# Update accuracy display
	var accuracy_percent = int(success_metric * 100)
	$CanvasLayer/VBoxContainer/LabelStatus.text = "Accuracy: %d%%" % accuracy_percent
	
	# Color feedback on accuracy label
	if success_metric > 0.9:
		$CanvasLayer/VBoxContainer/LabelStatus.add_theme_color_override("font_color", UITheme.COLOR_SUCCESS)
	elif success_metric > 0.7:
		$CanvasLayer/VBoxContainer/LabelStatus.add_theme_color_override("font_color", UITheme.COLOR_ACCENT_CYAN)
	else:
		$CanvasLayer/VBoxContainer/LabelStatus.add_theme_color_override("font_color", UITheme.COLOR_ACCENT_PURPLE)
	
	# Update frequency indicators positions
	var scope_x = 200
	var scope_width = 752
	target_indicator.position = Vector2(scope_x + target_frequency * scope_width - 3, 150)
	current_indicator.position = Vector2(scope_x + current_frequency * scope_width - 3, 150)
	
	# Animate frequency bars based on accuracy
	var time = Time.get_ticks_msec() * 0.001
	for i in range(frequency_bars.size()):
		var bar = frequency_bars[i]
		var bar_freq = float(i) / 9.0
		var distance_from_current = abs(bar_freq - current_frequency)
		
		# Bars near current frequency light up
		var activation = 1.0 - clamp(distance_from_current * 5.0, 0.0, 1.0)
		var wave = sin(time * 3.0 + i * 0.5) * 0.5 + 0.5
		var height = 10 + activation * wave * 150 * (0.5 + success_metric * 0.5)
		
		bar.size.y = height
		bar.position.y = 500 - height
		
		# Color based on accuracy
		if activation > 0.3:
			bar.color = lerp(UITheme.COLOR_ACCENT_PURPLE, UITheme.COLOR_ACCENT_CYAN, success_metric)
		else:
			bar.color = UITheme.COLOR_ACCENT_CYAN.darkened(0.5)

func _on_slider_changed(value):
	current_frequency = value
	var diff = abs(current_frequency - target_frequency)
	# More precise tuning required - need to be within 10% for full success
	success_metric = clamp(1.0 - (diff * 10.0), 0.0, 1.0)

func _on_Timer_timeout():
	time_left -= 1.0
	if time_left <= 0:
		finish_task()
	else:
		$Timer.start()

func finish_task():
	var delta := {
		"oscillation": (success_metric - 0.5) * 1.0,
		"stability": (success_metric - 0.5) * 0.6,
		"order": (success_metric - 0.5) * 0.3
	}
	
	emit_signal("task_completed", task_index, delta)
	queue_free()
