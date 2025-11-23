extends Control

signal ending_complete

const UITheme = preload("res://scripts/UITheme.gd")

var crystals = []

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
	
	# Create crystalline ordered pattern (hexagonal grid)
	var center = Vector2(576, 324)
	var spacing = 60
	for q in range(-4, 5):
		for r in range(-4, 5):
			if abs(q + r) > 4:
				continue
			# Hex grid coordinates
			var x = spacing * (q * sqrt(3) + r * sqrt(3)/2)
			var y = spacing * (r * 3.0/2)
			
			var crystal = ColorRect.new()
			crystal.size = Vector2(30, 30)
			crystal.position = center + Vector2(x, y) - Vector2(15, 15)
			crystal.rotation = PI / 4
			crystal.color = UITheme.COLOR_SUCCESS
			crystal.z_index = 1
			crystal.mouse_filter = Control.MOUSE_FILTER_IGNORE
			add_child(crystal)
			crystals.append(crystal)
	
	$VBoxContainer/Title.text = "HARMONIC GARDEN"
	$VBoxContainer/Description.text = "The Field achieves perfect harmony.\nOrder and stability reign supreme.\nA crystalline paradise of infinite patterns."
	$VBoxContainer/RestartButton.pressed.connect(_on_restart)
	
	# Make sure UI is above visuals
	$VBoxContainer.z_index = 200
	$VBoxContainer.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Style UI
	UITheme.apply_theme_to_label($VBoxContainer/Title, 36)
	$VBoxContainer/Title.add_theme_color_override("font_color", UITheme.COLOR_SUCCESS)
	UITheme.apply_theme_to_label($VBoxContainer/Description, 20)
	UITheme.apply_theme_to_button($VBoxContainer/RestartButton)

func _process(_delta):
	# Synchronized pulsing
	var time = Time.get_ticks_msec() * 0.001
	var pulse = sin(time * 3.0) * 0.15 + 1.0
	for crystal in crystals:
		crystal.scale = Vector2.ONE * pulse
		crystal.modulate.a = 0.8

func _on_restart():
	get_tree().reload_current_scene()
