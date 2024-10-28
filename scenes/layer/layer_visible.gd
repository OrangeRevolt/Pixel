extends Button


func _on_button_up() -> void:
	if ProgramData.canvas_meta["layers"][owner.get_index()].base_layer == false:
		ProgramData.canvas_meta["layers"][owner.get_index()].visible = !ProgramData.canvas_meta["layers"][owner.get_index()].visible
		print(owner.get_index())
		if ProgramData.canvas_meta["layers"][owner.get_index()].visible == true:
			icon = load("res://assets/svgs/eye.svg")
		else:
			icon = load("res://assets/svgs/eye_closed.svg")
			
		GlobalSignals.redraw_canvas.emit()
