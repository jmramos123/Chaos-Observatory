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
	
	# Create chaotic spiral particles
	var center = Vector2(576, 324)
	for i in range(80):
		var particle = ColorRect.new()
		particle.size = Vector2(12, 12)
		var angle = randf() * TAU
		var radius = randf_range(50, 250)
		particle.position = center + Vector2(cos(angle), sin(angle)) * radius - Vector2(6, 6)
		particle.color = UITheme.COLOR_ACCENT_PURPLE
		particle.z_index = 1
		particle.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(particle)
		particles.append({
			"rect": particle,
			"angle": angle,
			"radius": radius,
			"speed": randf_range(1.5, 3.5)
		})
	
	$VBoxContainer/Title.text = "STORM SPIRAL"
	$VBoxContainer/Description.text = "The Field becomes chaos incarnate.\nEntropy and oscillation intertwined.\nA maelstrom of competing energies."
	$VBoxContainer/RestartButton.pressed.connect(_on_restart)
	
	# Make sure UI is above visuals
	$VBoxContainer.z_index = 200
	$VBoxContainer.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Style UI
	UITheme.apply_theme_to_label($VBoxContainer/Title, 36)
	$VBoxContainer/Title.add_theme_color_override("font_color", UITheme.COLOR_DANGER)
	UITheme.apply_theme_to_label($VBoxContainer/Description, 20)
	UITheme.apply_theme_to_button($VBoxContainer/RestartButton)

func _process(_delta):
	# Spiraling chaotic motion
	var center = Vector2(576, 324)
	for particle_data in particles:
		particle_data.angle += particle_data.speed * _delta
		particle_data.radius += sin(particle_data.angle * 3) * 20 * _delta
		particle_data.radius = clamp(particle_data.radius, 50, 280)
		
		var pos = center + Vector2(cos(particle_data.angle), sin(particle_data.angle)) * particle_data.radius
		particle_data.rect.position = pos - Vector2(6, 6)
		particle_data.rect.rotation += _delta * 5

func _on_restart():
	get_tree().reload_current_scene()
