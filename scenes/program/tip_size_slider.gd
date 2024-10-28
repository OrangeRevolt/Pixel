extends HSlider


func _on_value_changed(s_value: float) -> void:
	ProgramData.canvas_meta["tool_tip_size"] = s_value
