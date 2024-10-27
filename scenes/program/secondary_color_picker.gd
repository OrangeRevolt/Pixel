extends ColorPickerButton


func _on_color_changed(s_color: Color) -> void:
	ProgramData.canvas_meta["secondary_color"] = s_color
	#print(ProgramData.canvas_meta["secondary_color"])
