extends Button


func _on_pressed() -> void:
	ProgramData.canvas_meta["name"] = %Canvas_Name_LineEdit.text
	ProgramData.canvas_meta["size"] = Vector2i(int(%Canvas_Width_SpinBox.value),int(%Canvas_Height_Spinbox.value))
	ProgramData.canvas_meta["color"] = %Canvas_Color_ColorPicker.color
	GlobalSignals.popup_exited.emit()
	GlobalSignals.create_user_canvas.emit()
	GlobalSignals.enable_menu_options.emit()
	GlobalSignals.redraw_gui_nodes.emit()
	owner.get_parent().remove_child(owner)
	owner.queue_free()
