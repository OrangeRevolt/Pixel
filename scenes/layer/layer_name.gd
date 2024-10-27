extends LineEdit


func _on_text_changed(new_text: String) -> void:
	ProgramData.canvas_meta["layers"][owner.get_index()] = new_text
