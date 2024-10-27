extends Label



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if ProgramData.canvas_meta["layers"].size() > 0:
		text = ProgramData.canvas_meta["name"] + "  " + "FPS:" + str(Engine.get_frames_per_second())
