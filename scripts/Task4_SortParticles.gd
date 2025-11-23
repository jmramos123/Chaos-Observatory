extends Node2D

signal task_completed(task_index: int, delta: Dictionary)

const TaskVisualHelper = preload("res://scripts/TaskVisualHelper.gd")
const UITheme = preload("res://scripts/UITheme.gd")

var task_index := 4
var success_metric := 0.0
var max_time := 15.0
var time_left := 15.0
var task_finished := false

# Particle system
var particles = []
var target_pattern = []
var particle_size = 20.0
var dragging_particle = null

func _ready():
	TaskVisualHelper.setup_task_background(self)
	TaskVisualHelper.apply_task_ui_theme(self)
	$CanvasLayer/VBoxContainer/LabelInstructions.text = "Drag Particles to Match Pattern"
	
	# Hide old scene button
	if has_node("CanvasLayer/VBoxContainer/SortButton"):
		$CanvasLayer/VBoxContainer/SortButton.visible = false
	
	time_left = max_time
	$Timer.start()
	
	setup_particle_system()

func setup_particle_system():
	# Create target pattern (a simple formation)
	var center = Vector2(576, 324)
	target_pattern = [
		center + Vector2(-60, -60),
		center + Vector2(60, -60),
		center + Vector2(-60, 60),
		center + Vector2(60, 60),
		center + Vector2(0, 0)
	]
	
	# Draw target pattern (faded circles)
	for pos in target_pattern:
		var target_indicator = ColorRect.new()
		target_indicator.position = pos - Vector2(particle_size/2, particle_size/2)
		target_indicator.size = Vector2(particle_size, particle_size)
		target_indicator.color = UITheme.COLOR_ACCENT_PURPLE
		target_indicator.modulate.a = 0.3
		add_child(target_indicator)
	
	# Create draggable particles in random positions
	for i in range(5):
		var particle = ColorRect.new()
		particle.size = Vector2(particle_size, particle_size)
		particle.color = UITheme.COLOR_ACCENT_CYAN
		particle.position = Vector2(randf() * 1000 + 76, randf() * 500 + 74)
		add_child(particle)
		particles.append(particle)
	
	# Sort button
	var sort_btn = Button.new()
	sort_btn.text = "SORT PARTICLES"
	sort_btn.position = Vector2(450, 550)
	sort_btn.size = Vector2(200, 50)
	UITheme.apply_theme_to_button(sort_btn)
	sort_btn.pressed.connect(_on_sort_pressed)
	add_child(sort_btn)

func _on_sort_pressed():
	# Move particles randomly toward their targets (imperfect sorting)
	for i in range(particles.size()):
		var target_pos = target_pattern[i] - Vector2(particle_size/2, particle_size/2)
		var current_pos = particles[i].position
		# Add randomness - sometimes moves closer, sometimes not quite right
		var random_offset = Vector2(randf() * 60 - 30, randf() * 60 - 30)
		var new_pos = lerp(current_pos, target_pos, 0.3 + randf() * 0.4) + random_offset
		particles[i].position = new_pos

func start_task(index: int):
	task_index = index

func _process(_delta_time):
	$CanvasLayer/VBoxContainer/LabelTimer.text = "Time: %.0f" % time_left
	
	# Calculate how well particles match the pattern
	var total_distance = 0.0
	for i in range(particles.size()):
		var particle_center = particles[i].position + Vector2(particle_size/2, particle_size/2)
		var dist = particle_center.distance_to(target_pattern[i])
		total_distance += dist
	
	# Success based on average distance (lower is better)
	var avg_distance = total_distance / particles.size()
	success_metric = clamp(1.0 - (avg_distance / 200.0), 0.0, 1.0)
	
	$CanvasLayer/VBoxContainer/LabelStatus.text = "Alignment: %.1f%%" % (success_metric * 100.0)
	
	# Visual feedback - particles glow when close to target
	for i in range(particles.size()):
		var particle_center = particles[i].position + Vector2(particle_size/2, particle_size/2)
		var dist = particle_center.distance_to(target_pattern[i])
		var closeness = clamp(1.0 - (dist / 100.0), 0.0, 1.0)
		particles[i].modulate = Color(1, 1, 1, 0.5 + closeness * 0.5)

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
		"order": (success_metric - 0.5) * 1.2,
		"entropy": (0.5 - success_metric) * 0.7
	}
	
	emit_signal("task_completed", task_index, delta)
