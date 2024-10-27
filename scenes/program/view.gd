extends PopupMenu


func _ready() -> void:
	GlobalSignals.enable_menu_options.connect(Callable(self,"_enable_options"))
	
func _enable_options():
	set_item_disabled(0,false) 


func _on_id_pressed(id: int) -> void:
	if id == 0: #grid
		ProgramData.canvas_meta["grid"] = !ProgramData.canvas_meta["grid"]
		GlobalSignals.update_shaders.emit()
