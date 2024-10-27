extends Button


func _on_pressed() -> void:
	ProgramData.canvas_meta["selected_layer"] = owner.get_index()
	GlobalSignals.redraw_gui_nodes.emit()
