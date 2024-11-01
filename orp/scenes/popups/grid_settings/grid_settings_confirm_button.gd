extends Button


func _on_pressed() -> void:
	ProgramData.canvas_meta["grid_cell_size"] = Vector2i(int(%Cell_Width_SpinBox.value),int(%Cell_Height_SpinBox.value))
	ProgramData.canvas_meta["grid_color"] = %Grid_Color_ColorPicker.color
	GlobalSignals.update_shaders.emit()
	GlobalSignals.popup_exited.emit()
	owner.get_parent().remove_child(owner)
	owner.queue_free()
