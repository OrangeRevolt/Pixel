extends ColorPickerButton


func _on_color_changed(p_color: Color) -> void:
	ProgramData.canvas_meta["primary_color"] = p_color
	#print(ProgramData.canvas_meta["primary_color"])
