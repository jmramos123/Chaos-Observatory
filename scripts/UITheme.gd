extends Node

# Sci-fi color palette
const COLOR_BG_DARK = Color(0.05, 0.08, 0.12)
const COLOR_BG_MID = Color(0.08, 0.12, 0.18)
const COLOR_ACCENT_CYAN = Color(0.2, 0.8, 1.0)
const COLOR_ACCENT_PURPLE = Color(0.6, 0.3, 1.0)
const COLOR_WARNING = Color(1.0, 0.6, 0.2)
const COLOR_DANGER = Color(1.0, 0.3, 0.3)
const COLOR_SUCCESS = Color(0.3, 1.0, 0.5)
const COLOR_TEXT = Color(0.9, 0.95, 1.0)

static func create_panel_style() -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = COLOR_BG_MID
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = COLOR_ACCENT_CYAN
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.shadow_size = 4
	style.shadow_color = Color(0, 0, 0, 0.5)
	return style

static func create_button_style() -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = COLOR_ACCENT_CYAN.darkened(0.3)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = COLOR_ACCENT_CYAN
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	style.content_margin_left = 20
	style.content_margin_right = 20
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	return style

static func create_button_hover_style() -> StyleBoxFlat:
	var style = create_button_style()
	style.bg_color = COLOR_ACCENT_CYAN.darkened(0.1)
	return style

static func create_button_pressed_style() -> StyleBoxFlat:
	var style = create_button_style()
	style.bg_color = COLOR_ACCENT_CYAN
	return style

static func apply_theme_to_button(button: Button):
	button.add_theme_stylebox_override("normal", create_button_style())
	button.add_theme_stylebox_override("hover", create_button_hover_style())
	button.add_theme_stylebox_override("pressed", create_button_pressed_style())
	button.add_theme_color_override("font_color", COLOR_TEXT)
	button.add_theme_color_override("font_hover_color", COLOR_TEXT)
	button.add_theme_color_override("font_pressed_color", COLOR_BG_DARK)
	button.add_theme_font_size_override("font_size", 18)

static func apply_theme_to_panel(panel: Panel):
	panel.add_theme_stylebox_override("panel", create_panel_style())

static func apply_theme_to_label(label: Control, size: int = 16):
	# Works with both Label and RichTextLabel
	label.add_theme_color_override("font_color", COLOR_TEXT)
	label.add_theme_color_override("default_color", COLOR_TEXT)  # For RichTextLabel
	label.add_theme_font_size_override("font_size", size)
