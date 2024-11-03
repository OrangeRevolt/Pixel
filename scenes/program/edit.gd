extends PopupMenu


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalSignals.enable_menu_options.connect(Callable(self,"_enable_options"))
	
func _enable_options():
	set_item_disabled(0,false) 
	set_item_disabled(1,false) 
	if %Canvas_Texture.image_history.size() > 0:
		set_item_disabled(2,false)
	else:
		set_item_disabled(2,true)
		set_item_disabled(3,true)

func _on_id_pressed(id: int) -> void:
	if id == 0: #Grid Settings
		%Popup_Group.add_child(preload("res://scenes/popups/grid_settings/canvas_settings.tscn").instantiate())
		%Program_VBox.hide()
		%Canvas_Texture.set_process(false)
	if id == 1: #Resize Canvas
		%Popup_Group.add_child(preload("res://scenes/popups/resize_canvas/resize_canvas.tscn").instantiate())
		%Program_VBox.hide()
		%Canvas_Texture.set_process(false)
	if id == 2: #Undo
		GlobalSignals.undo.emit()
	if id == 3: #Redo
		GlobalSignals.redo.emit()
