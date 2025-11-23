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
	
	# Create frozen/collapsed particles moving to center
	var center = Vector2(576, 324)
	for i in range(60):
		var particle = ColorRect.new()
		particle.size = Vector2(15, 15)
		var angle = (float(i) / 60) * TAU
		var radius = 250
		particle.position = center + Vector2(cos(angle), sin(angle)) * radius - Vector2(7.5, 7.5)
		particle.color = Color(0.3, 0.5, 0.8, 0.9)  # Frozen blue-gray
		particle.z_index = 1
		particle.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(particle)
		particles.append({
			"rect": particle,
			"start_pos": particle.position,
			"progress": 0.0
		})
	
	$VBoxContainer/Title.text = "FROZEN COLLAPSE"
	$VBoxContainer/Description.text = "The Field succumbs to entropy.\nAll motion ceases, energy drains.\nA cold, silent collapse into stasis."
	$VBoxContainer/RestartButton.pressed.connect(_on_restart)
	
	# Make sure UI is above visuals
	$VBoxContainer.z_index = 200
	$VBoxContainer.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Style UI
	UITheme.apply_theme_to_label($VBoxContainer/Title, 36)
	$VBoxContainer/Title.add_theme_color_override("font_color", Color(0.4, 0.6, 1.0))
	UITheme.apply_theme_to_label($VBoxContainer/Description, 20)
	UITheme.apply_theme_to_button($VBoxContainer/RestartButton)

func _process(_delta):
	# Slow collapse toward center
	var center = Vector2(576, 324)
	for particle_data in particles:
		particle_data.progress = min(particle_data.progress + _delta * 0.3, 1.0)
		var current_pos = particle_data.start_pos.lerp(center, particle_data.progress)
		particle_data.rect.position = current_pos - Vector2(7.5, 7.5)
		particle_data.rect.modulate.a = 1.0 - particle_data.progress * 0.5

func _on_restart():
	get_tree().reload_current_scene()
