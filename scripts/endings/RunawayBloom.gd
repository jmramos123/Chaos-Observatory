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
	
	# Create exploding/blooming particles
	var center = Vector2(576, 324)
	for i in range(100):
		var particle = ColorRect.new()
		particle.size = Vector2(10, 10)
		particle.position = center - Vector2(5, 5)
		var angle = randf() * TAU
		var speed = randf_range(80, 200)
		particle.color = Color.from_hsv(randf(), 0.9, 1.0)  # Rainbow colors
		particle.z_index = 1
		particle.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(particle)
		particles.append({
			"rect": particle,
			"velocity": Vector2(cos(angle), sin(angle)) * speed,
			"lifetime": 0.0
		})
	
	$VBoxContainer/Title.text = "RUNAWAY BLOOM"
	$VBoxContainer/Description.text = "The Field explodes into uncontrolled growth.\nEnergy cascades without limit.\nBeauty and destruction intertwined."
	$VBoxContainer/RestartButton.pressed.connect(_on_restart)
	
	# Make sure UI is above visuals
	$VBoxContainer.z_index = 200
	$VBoxContainer.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Style UI
	UITheme.apply_theme_to_label($VBoxContainer/Title, 36)
	$VBoxContainer/Title.add_theme_color_override("font_color", UITheme.COLOR_WARNING)
	UITheme.apply_theme_to_label($VBoxContainer/Description, 20)
	UITheme.apply_theme_to_button($VBoxContainer/RestartButton)

func _process(_delta):
	# Explosive expansion
	for particle_data in particles:
		particle_data.lifetime += _delta
		var pos = particle_data.rect.position + particle_data.velocity * _delta
		particle_data.rect.position = pos
		
		# Fade out at edges
		var center = Vector2(576, 324)
		var dist = pos.distance_to(center)
		particle_data.rect.modulate.a = max(0.0, 1.0 - dist / 400.0)
		
		# Respawn if too far
		if dist > 400:
			particle_data.rect.position = center - Vector2(5, 5)
			particle_data.lifetime = 0.0

func _on_restart():
	get_tree().reload_current_scene()
