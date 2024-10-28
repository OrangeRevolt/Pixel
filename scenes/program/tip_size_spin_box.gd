extends SpinBox


func _on_value_changed(tip_value: float) -> void:
	ProgramData.canvas_meta["tool_tip_size"] = int(round(tip_value))
