extends Node

# Apply common visual setup to all task scenes
# Call this from each task's _ready() function

const UITheme = preload("res://scripts/UITheme.gd")

static func setup_task_background(task_node: Node2D):
	# Dark base background
	var bg = ColorRect.new()
	bg.color = UITheme.COLOR_BG_DARK
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.z_index = -100
	task_node.add_child(bg)
	
	# Scientific grid overlay
	create_scientific_grid(task_node)
	
	# Corner indicators
	create_corner_indicators(task_node)

static func create_scientific_grid(task_node: Node2D):
	# Subtle grid lines
	var grid_color = Color(0.2, 0.4, 0.5, 0.15)
	var spacing = 50
	
	# Vertical lines
	for x in range(0, 1152, spacing):
		var line = ColorRect.new()
		line.position = Vector2(x, 0)
		line.size = Vector2(1, 648)
		line.color = grid_color
		line.z_index = -90
		task_node.add_child(line)
	
	# Horizontal lines
	for y in range(0, 648, spacing):
		var line = ColorRect.new()
		line.position = Vector2(0, y)
		line.size = Vector2(1152, 1)
		line.color = grid_color
		line.z_index = -90
		task_node.add_child(line)
	
	# Accent lines (thicker at center)
	var center_v = ColorRect.new()
	center_v.position = Vector2(576, 0)
	center_v.size = Vector2(2, 648)
	center_v.color = Color(0.2, 0.6, 0.7, 0.3)
	center_v.z_index = -90
	task_node.add_child(center_v)
	
	var center_h = ColorRect.new()
	center_h.position = Vector2(0, 324)
	center_h.size = Vector2(1152, 2)
	center_h.color = Color(0.2, 0.6, 0.7, 0.3)
	center_h.z_index = -90
	task_node.add_child(center_h)

static func create_corner_indicators(task_node: Node2D):
	var corner_color = Color(0.3, 0.7, 0.8, 0.4)
	var corner_size = 40
	var corner_thickness = 3
	
	var corners = [
		Vector2(20, 20),           # Top-left
		Vector2(1132, 20),         # Top-right
		Vector2(20, 628),          # Bottom-left
		Vector2(1132, 628)         # Bottom-right
	]
	
	for corner_pos in corners:
		# Horizontal bracket
		var h_bracket = ColorRect.new()
		h_bracket.position = corner_pos
		h_bracket.size = Vector2(corner_size, corner_thickness)
		h_bracket.color = corner_color
		h_bracket.z_index = -90
		task_node.add_child(h_bracket)
		
		# Vertical bracket
		var v_bracket = ColorRect.new()
		v_bracket.position = corner_pos
		v_bracket.size = Vector2(corner_thickness, corner_size)
		v_bracket.color = corner_color
		v_bracket.z_index = -90
		task_node.add_child(v_bracket)
		
		# Adjust for right/bottom corners
		if corner_pos.x > 500:
			h_bracket.position.x -= corner_size
		if corner_pos.y > 400:
			v_bracket.position.y -= corner_size

static func apply_task_ui_theme(task_node: Node2D):
	# Apply theme to common UI elements
	var instructions = task_node.get_node_or_null("CanvasLayer/VBoxContainer/LabelInstructions")
	if instructions:
		UITheme.apply_theme_to_label(instructions, 24)
		instructions.add_theme_color_override("font_color", UITheme.COLOR_ACCENT_CYAN)
	
	var timer_label = task_node.get_node_or_null("CanvasLayer/VBoxContainer/LabelTimer")
	if timer_label:
		UITheme.apply_theme_to_label(timer_label, 20)
	
	var status_label = task_node.get_node_or_null("CanvasLayer/VBoxContainer/LabelStatus")
	if status_label:
		UITheme.apply_theme_to_label(status_label, 18)
		status_label.add_theme_color_override("font_color", UITheme.COLOR_SUCCESS)
	
	# Style all buttons
	apply_theme_to_all_buttons(task_node)

static func apply_theme_to_all_buttons(node: Node):
	for child in node.get_children():
		if child is Button:
			UITheme.apply_theme_to_button(child)
		apply_theme_to_all_buttons(child)
