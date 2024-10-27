extends VBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalSignals.popup_exited.connect(Callable(self,"_unhide_self"))
	
func _unhide_self():
	set_process_input(true)
	%Canvas_Texture.set_process(true)
	visible = true
