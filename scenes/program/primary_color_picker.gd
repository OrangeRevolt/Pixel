extends ColorPickerButton


func _on_color_changed(p_color: Color) -> void:
	ProgramData.canvas_meta["primary_color"] = p_color
	#print(ProgramData.canvas_meta["primary_color"])


func _on_pressed() -> void:
	GlobalSignals.popup_open.emit()


func _on_popup_closed() -> void:
	GlobalSignals.popup_exited.emit()
