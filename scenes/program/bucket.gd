extends Button


func _on_pressed() -> void:
	ProgramData.canvas_meta["selected_tool"] = ProgramData.BUCKET_TOOL
	#print(ProgramData.canvas_meta["selected_tool"])
