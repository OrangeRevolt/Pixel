extends Button


func _on_pressed() -> void:
	ProgramData.canvas_meta["size"] = Vector2i(%Resize_Canvas_Width_SpinBox.value,%Resize_Canvas_Height_SpinBox.value)
	GlobalSignals.resize_canvas.emit()
	GlobalSignals.popup_exited.emit()
	owner.get_parent().remove_child(owner)
	owner.queue_free()
