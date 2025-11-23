extends Node2D

signal task_completed(task_index: int, delta: Dictionary)

const TaskVisualHelper = preload("res://scripts/TaskVisualHelper.gd")
const UITheme = preload("res://scripts/UITheme.gd")

var task_index := 9
var success_metric := 0.0
var max_time := 15.0
var time_left := 15.0
var task_finished := false

var containment_strength := 0.0  # Player adjusts this - starts at 0
var particles_visual = []
var target_zone_radius := 130.0  # Outer boundary
var inner_exclusion_radius := 50.0  # Inner boundary (donut hole)
var center_pos := Vector2(576, 324)

func _ready():
	TaskVisualHelper.setup_task_background(self)
	TaskVisualHelper.apply_task_ui_theme(self)
	$CanvasLayer/VBoxContainer/LabelInstructions.text = "Contain Energy Particles in Target Zone"
	
	# Disconnect scene buttons
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
	
	setup_diffusion_field()

func setup_diffusion_field():
	# Draw outer ring (target zone)
	var outer_ring = ColorRect.new()
	outer_ring.position = center_pos - Vector2(target_zone_radius, target_zone_radius)
	outer_ring.size = Vector2(target_zone_radius * 2, target_zone_radius * 2)
	outer_ring.color = UITheme.COLOR_SUCCESS
	outer_ring.modulate.a = 0.2
	add_child(outer_ring)
	
	# Draw inner exclusion zone (donut hole)
	var inner_ring = ColorRect.new()
	inner_ring.position = center_pos - Vector2(inner_exclusion_radius, inner_exclusion_radius)
	inner_ring.size = Vector2(inner_exclusion_radius * 2, inner_exclusion_radius * 2)
	inner_ring.color = UITheme.COLOR_DANGER
	inner_ring.modulate.a = 0.3
	inner_ring.z_index = 1
	add_child(inner_ring)
	
	# Zone labels
	var zone_label = Label.new()
	zone_label.text = "TARGET RING"
	zone_label.position = center_pos - Vector2(60, 180)
	UITheme.apply_theme_to_label(zone_label, 18)
	zone_label.add_theme_color_override("font_color", UITheme.COLOR_SUCCESS)
	add_child(zone_label)
	
	var inner_label = Label.new()
	inner_label.text = "X"
	inner_label.position = center_pos - Vector2(10, 10)
	UITheme.apply_theme_to_label(inner_label, 32)
	inner_label.add_theme_color_override("font_color", UITheme.COLOR_DANGER)
	inner_label.z_index = 2
	add_child(inner_label)
	
	# Create particles scattered just outside the target ring
	for i in range(25):
		var particle = ColorRect.new()
		particle.size = Vector2(12, 12)
		particle.color = UITheme.COLOR_ACCENT_CYAN
		# Start particles just outside the outer ring
		var angle = randf() * TAU
		var radius = target_zone_radius + 20.0 + randf() * 30.0  # 20-50 pixels outside
		particle.position = center_pos + Vector2(cos(angle), sin(angle)) * radius - Vector2(6, 6)
		# Start with zero velocity - player must act
		particle.set_meta("velocity", Vector2.ZERO)
		particle.z_index = 5
		add_child(particle)
		particles_visual.append(particle)
	
	# Control buttons (centered)
	var weaken_btn = Button.new()
	weaken_btn.text = "◄ WEAKEN FIELD"
	weaken_btn.position = Vector2(350, 540)
	weaken_btn.size = Vector2(160, 50)
	UITheme.apply_theme_to_button(weaken_btn)
	weaken_btn.pressed.connect(_on_adjust_containment.bind(-0.15))
	add_child(weaken_btn)
	
	var strengthen_btn = Button.new()
	strengthen_btn.text = "STRENGTHEN FIELD ►"
	strengthen_btn.position = Vector2(642, 540)
	strengthen_btn.size = Vector2(160, 50)
	UITheme.apply_theme_to_button(strengthen_btn)
	strengthen_btn.pressed.connect(_on_adjust_containment.bind(0.15))
	add_child(strengthen_btn)

func start_task(index: int):
	task_index = index

func _process(delta_time):
	$CanvasLayer/VBoxContainer/LabelTimer.text = "Time: %.0f" % time_left
	
	# Count particles in valid ring (between inner and outer)
	var particles_in_ring = 0
	
	for particle in particles_visual:
		var vel = particle.get_meta("velocity")
		var particle_center = particle.position + Vector2(6, 6)
		var to_center = center_pos - particle_center
		var distance = to_center.length()
		
		# Natural spreading force (particles want to disperse outward)
		var spread_force = Vector2.ZERO
		if distance > 0.1:
			spread_force = -to_center.normalized() * 40.0
		
		# Containment field pulls particles toward center (controlled by player)
		var containment_force = Vector2.ZERO
		if distance > 0.1:
			containment_force = to_center.normalized() * containment_strength * 200.0
		
		# Apply forces
		vel += spread_force * delta_time
		vel += containment_force * delta_time
		
		# Damping
		vel *= 0.95
		
		# Update position
		particle.position += vel * delta_time
		particle.set_meta("velocity", vel)
		
		# Check if in valid ring (donut)
		var in_ring = distance >= inner_exclusion_radius and distance <= target_zone_radius
		if in_ring:
			particles_in_ring += 1
		
		# Color based on position
		if distance < inner_exclusion_radius:
			particle.color = UITheme.COLOR_DANGER  # Too close (in red zone)
		elif distance <= target_zone_radius:
			particle.color = UITheme.COLOR_SUCCESS  # Perfect (in green ring)
		else:
			particle.color = UITheme.COLOR_WARNING  # Too far (escaped)
	
	# Success metric: percentage in valid ring
	var ring_ratio = float(particles_in_ring) / float(particles_visual.size())
	success_metric = ring_ratio
	
	$CanvasLayer/VBoxContainer/LabelStatus.text = "In Ring: %d/%d (%.0f%%)" % [particles_in_ring, particles_visual.size(), success_metric * 100]

func _on_adjust_containment(amount: float):
	containment_strength = clamp(containment_strength + amount, 0.0, 1.0)

func adjust_diffusion(amount: float):
	# Keep for scene file compatibility
	_on_adjust_containment(amount)

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
		"entropy": (0.5 - success_metric) * 1.0,
		"stability": (success_metric - 0.5) * 0.8
	}
	
	emit_signal("task_completed", task_index, delta)
