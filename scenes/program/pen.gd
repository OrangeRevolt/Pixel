extends Button


func _on_pressed() -> void:
	ProgramData.canvas_meta["selected_tool"] = ProgramData.PEN_TOOL
	#print(ProgramData.canvas_meta["tool_selected"])
