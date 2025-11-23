extends Control

const UITheme = preload("res://scripts/UITheme.gd")

var task_scenes := [
	"res://scenes/tasks/Task1_AlignCrystals.tscn",
	"res://scenes/tasks/Task2_TuneResonance.tscn",
	"res://scenes/tasks/Task3_BalanceTemperature.tscn",
	"res://scenes/tasks/Task4_SortParticles.tscn",
	"res://scenes/tasks/Task5_SequenceRunes.tscn",
	"res://scenes/tasks/Task6_StabilizeBeam.tscn",
	"res://scenes/tasks/Task7_AdjustValves.tscn",
	"res://scenes/tasks/Task8_CalibrateGrid.tscn",
	"res://scenes/tasks/Task9_ControlDiffusion.tscn",
	"res://scenes/tasks/Task10_FinalAlignment.tscn"
]

var current_task := 0
var game_started := false

@onready var intro_panel = $IntroPanel
@onready var start_button = $IntroPanel/VBoxContainer/StartButton
@onready var task_container = $TaskContainer

var door_left: ColorRect
var door_right: ColorRect

func _ready():
	# Apply sci-fi theme to intro
	setup_intro_theme()
	
	# Create portal-style doors
	create_portal_doors()

func setup_intro_theme():
	# Background - simple dark color
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = UITheme.COLOR_BG_DARK
	intro_panel.add_child(bg)
	intro_panel.move_child(bg, 0)
	
	# Apply panel theme
	UITheme.apply_theme_to_panel(intro_panel)
	
	# Apply button theme
	UITheme.apply_theme_to_button(start_button)
	
	# Apply label themes
	var title = intro_panel.get_node("VBoxContainer/Title")
	UITheme.apply_theme_to_label(title, 48)
	title.add_theme_color_override("font_color", UITheme.COLOR_ACCENT_CYAN)
	
	var subtitle = intro_panel.get_node("VBoxContainer/Subtitle")
	UITheme.apply_theme_to_label(subtitle, 20)
	subtitle.add_theme_color_override("font_color", UITheme.COLOR_ACCENT_PURPLE)
	
	var description = intro_panel.get_node("VBoxContainer/Description")
	UITheme.apply_theme_to_label(description, 16)

func create_portal_doors():
	# Left door panel
	door_left = ColorRect.new()
	door_left.size = Vector2(576, 648)
	door_left.position = Vector2(-576, 0)  # Start off-screen left
	door_left.color = Color(0.1, 0.15, 0.2, 1.0)
	door_left.z_index = 100
	add_child(door_left)
	
	# Add edge highlight to left door
	var left_edge = ColorRect.new()
	left_edge.size = Vector2(4, 648)
	left_edge.position = Vector2(572, 0)
	left_edge.color = UITheme.COLOR_ACCENT_CYAN
	door_left.add_child(left_edge)
	
	# Right door panel
	door_right = ColorRect.new()
	door_right.size = Vector2(576, 648)
	door_right.position = Vector2(1152, 0)  # Start off-screen right
	door_right.color = Color(0.1, 0.15, 0.2, 1.0)
	door_right.z_index = 100
	add_child(door_right)
	
	# Add edge highlight to right door
	var right_edge = ColorRect.new()
	right_edge.size = Vector2(4, 648)
	right_edge.position = Vector2(0, 0)
	right_edge.color = UITheme.COLOR_ACCENT_CYAN
	door_right.add_child(right_edge)

func close_doors():
	# Animate doors closing
	var tween = create_tween().set_parallel(true)
	tween.tween_property(door_left, "position:x", 0.0, 0.75).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(door_right, "position:x", 576.0, 0.75).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	await tween.finished

func open_doors():
	# Animate doors opening
	var tween = create_tween().set_parallel(true)
	tween.tween_property(door_left, "position:x", -576.0, 0.75).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(door_right, "position:x", 1152.0, 0.75).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	await tween.finished

func _on_StartButton_pressed():
	if intro_panel:
		intro_panel.visible = false
	game_started = true
	FieldManager.reset_all()
	current_task = 0
	start_next_task()

func start_next_task():
	if current_task >= task_scenes.size():
		show_evolution()
		return

	# Close doors first
	await close_doors()
	
	var scene = load(task_scenes[current_task]).instantiate()
	task_container.add_child(scene)
	
	# Connect signal immediately
	scene.connect("task_completed", Callable(self, "_on_task_completed"))
	
	# Call start_task on next frame to ensure node is ready
	await get_tree().process_frame
	scene.start_task(current_task + 1)
	current_task += 1
	
	# Open doors to reveal new task
	await open_doors()

func _on_task_completed(task_index, delta):
	FieldManager.apply_task_delta(task_index, delta)
	
	# Close doors before clearing task
	await close_doors()
	
	# Clear previous task children
	for child in task_container.get_children():
		child.queue_free()
	
	# Wait a frame before loading next task
	await get_tree().process_frame
	start_next_task()

func show_evolution():
	# Open doors before showing evolution
	await open_doors()
	
	# Load evolution visualization scene
	var evolution_scene = load("res://scenes/main/Evolution.tscn")
	if evolution_scene:
		var evolution = evolution_scene.instantiate()
		add_child(evolution)
	else:
		# Fallback: just go straight to ending
		await get_tree().create_timer(2.0).timeout
		show_ending()

func show_ending():
	var final_state = FieldManager.evolve_field()
	var ending_name = FieldManager.determine_ending(final_state)
	
	print("=== FINAL STATE ===")
	print(final_state)
	print("=== ENDING: ", ending_name, " ===")
	
	# Load appropriate ending scene
	var ending_path = "res://scenes/endings/" + ending_name + ".tscn"
	var ending_scene = load(ending_path)
	if ending_scene:
		var ending = ending_scene.instantiate()
		add_child(ending)
	else:
		# Fallback ending display
		var label = Label.new()
		label.text = "ENDING: " + ending_name.capitalize().replace("_", " ")
		label.position = Vector2(400, 300)
		add_child(label)
