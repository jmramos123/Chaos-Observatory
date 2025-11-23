extends Control

@onready var tasks_container = $TasksContainer
var tasks: Array[String] = [
	"Align the chaos field",
	"Calibrate resonance nodes",
	"Analyze entropy drift",
]

func _ready():
	load_tasks()

func load_tasks():
	tasks_container.queue_free_children()

	for t in tasks:
		var task_scene = load("res://scenes/tasks/TaskTemplate.tscn").instantiate()
		task_scene.setup(t, false)
		tasks_container.add_child(task_scene)
