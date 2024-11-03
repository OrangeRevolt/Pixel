extends Button

func _ready() -> void:
	GlobalSignals.enable_menu_options.connect(Callable(self,"_enable_self"))


func _enable_self():
	disabled = false


func _on_pressed() -> void:
	%Canvas_Texture.add_history(ProgramData.canvas_meta["layers"][ProgramData.canvas_meta["selected_layer"]],ProgramData.canvas_meta["selected_layer"])
	GlobalSignals.flip_canvas_y.emit()
	%Canvas_Texture.add_history(ProgramData.canvas_meta["layers"][ProgramData.canvas_meta["selected_layer"]],ProgramData.canvas_meta["selected_layer"])
