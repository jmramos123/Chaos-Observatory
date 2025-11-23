extends Control

# Evolution visualization

var evolution_time := 0.0
var max_time := 5.0

@onready var progress_bar = $CenterContainer/VBoxContainer/ProgressBar
@onready var status_label = $CenterContainer/VBoxContainer/StatusLabel

func _ready():
	status_label.text = "EVOLVING THE FIELD..."
	progress_bar.max_value = max_time
	progress_bar.value = 0.0

func _process(delta):
	evolution_time += delta
	progress_bar.value = evolution_time
	
	if evolution_time >= max_time:
		finish_evolution()

func finish_evolution():
	set_process(false)
	# Signal back to Main to show ending
	if get_parent().has_method("show_ending"):
		get_parent().show_ending()
	queue_free()
