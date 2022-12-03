extends Label


# Called when the node enters the scene tree for the first time.
var timer = null
func _ready():
	timer = get_tree().create_timer(0.01)
	timer.timeout.connect(_on_timeout)

func _on_timeout():
	text = str(Engine.get_frames_per_second())
	timer = get_tree().create_timer(0.01)
	timer.timeout.connect(_on_timeout)
