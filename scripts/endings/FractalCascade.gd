extends Control

signal ending_complete

const UITheme = preload("res://scripts/UITheme.gd")

var branches = []

func _ready():
	# Set root mouse filter to allow clicks through
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Create dark background
	var bg = ColorRect.new()
	bg.color = UITheme.COLOR_BG_DARK
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.z_index = -1
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	
	# Create fractal branching pattern
	var center = Vector2(576, 324)
	generate_fractal(center, 150, -PI/2, 0, 4)
	
	$VBoxContainer/Title.text = "FRACTAL CASCADE"
	$VBoxContainer/Description.text = "The Field fractures into infinite complexity.\nRecursive patterns spawn endless variations.\nMathematical chaos unleashed."
	$VBoxContainer/RestartButton.pressed.connect(_on_restart)
	
	# Make sure UI is above visuals
	$VBoxContainer.z_index = 200
	$VBoxContainer.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Style UI
	UITheme.apply_theme_to_label($VBoxContainer/Title, 36)
	$VBoxContainer/Title.add_theme_color_override("font_color", UITheme.COLOR_ACCENT_PURPLE)
	UITheme.apply_theme_to_label($VBoxContainer/Description, 20)
	UITheme.apply_theme_to_button($VBoxContainer/RestartButton)

func generate_fractal(pos: Vector2, length: float, angle: float, depth: int, max_depth: int):
	if depth > max_depth or length < 10:
		return
	
	var end_pos = pos + Vector2(cos(angle), sin(angle)) * length
	
	# Create line as narrow ColorRect
	var branch = ColorRect.new()
	branch.size = Vector2(length, 3)
	branch.position = pos
	branch.rotation = angle
	var hue = float(depth) / max_depth
	branch.color = Color.from_hsv(hue * 0.7, 0.8, 1.0)
	branch.z_index = 1
	branch.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(branch)
	branches.append({"rect": branch, "depth": depth})
	
	# Recursive branches
	generate_fractal(end_pos, length * 0.7, angle - PI/4, depth + 1, max_depth)
	generate_fractal(end_pos, length * 0.7, angle + PI/4, depth + 1, max_depth)

func _process(_delta):
	# Pulsing animation based on depth
	var time = Time.get_ticks_msec() * 0.001
	for branch_data in branches:
		var pulse = sin(time * 3.0 + branch_data.depth * 0.5) * 0.3 + 0.7
		branch_data.rect.modulate.a = pulse

func _on_restart():
	get_tree().reload_current_scene()
