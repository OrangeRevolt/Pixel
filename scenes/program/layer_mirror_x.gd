extends Button

func _ready() -> void:
	GlobalSignals.enable_menu_options.connect(Callable(self,"_enable_self"))


func _enable_self():
	disabled = false


func _on_pressed() -> void:
	GlobalSignals.flip_canvas_x.emit()
