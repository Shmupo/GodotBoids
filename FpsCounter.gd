extends Label

func _ready():
	var timer: Timer = Timer.new()
	timer.autostart = true
	timer.timeout.connect(updateCounter)
	
	add_child(timer)
	updateCounter()
	timer.start(1)
	
func updateCounter() -> void:
	text = str(Engine.get_frames_per_second())
