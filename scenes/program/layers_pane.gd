extends PanelContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalSignals.enable_menu_options.connect(Callable(self,"_enable_layers_pane"))


func _enable_layers_pane():
	%Layer_Add.disabled = false
	%Layer_Remove.disabled = false
