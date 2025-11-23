extends Control

signal ending_complete

const UITheme = preload("res://scripts/UITheme.gd")

var particles = []

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
	
	# Create balanced grid of particles (stable equilibrium)
	var center = Vector2(576, 324)
	for x in range(-3, 4):
		for y in range(-3, 4):
			var particle = ColorRect.new()
			particle.size = Vector2(20, 20)
			particle.position = center + Vector2(x * 80, y * 80) - Vector2(10, 10)
			particle.color = UITheme.COLOR_ACCENT_CYAN
			particle.z_index = 1
			particle.mouse_filter = Control.MOUSE_FILTER_IGNORE
			add_child(particle)
			particles.append(particle)
	
	$VBoxContainer/Title.text = "STABLE EQUILIBRIUM"
	$VBoxContainer/Description.text = "The Field has found perfect balance.\nAll forces in harmony.\nA peaceful, sustainable existence."
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
	# Gentle pulsing animation
	var time = Time.get_ticks_msec() * 0.001
	for i in range(particles.size()):
		var particle = particles[i]
		var pulse = sin(time * 2.0) * 0.1 + 1.0
		particle.scale = Vector2.ONE * pulse
		particle.modulate.a = 0.7 + sin(time * 2.0) * 0.3

func _on_restart():
	get_tree().reload_current_scene()
