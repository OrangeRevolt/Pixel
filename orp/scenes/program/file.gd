extends PopupMenu


func _ready() -> void:
	GlobalSignals.enable_menu_options.connect(Callable(self,"_enable_options"))
	

func _enable_options():
	set_item_disabled(2,false) 
	set_item_disabled(3,false) 


func _on_id_pressed(id: int) -> void:
	if id == 0: #new
		%Popup_Group.add_child(preload("res://scenes/popups/new_canvas/new_canvas.tscn").instantiate())
		%Program_VBox.hide()
		%Canvas_Texture.set_process(false)
	elif id == 1: #load
		%Load_FileDialog.popup_centered(Vector2i(500,400))
	elif id == 2: #export
		%Export_FileDialog.get_line_edit().text = ProgramData.canvas_meta["name"]
		%Export_FileDialog.popup_centered(Vector2i(500,400))
	elif id == 3: #save
		%Save_FileDialog.get_line_edit().text = ProgramData.canvas_meta["name"]
		%Save_FileDialog.popup_centered(Vector2i(500,400))
	elif id == 4: #exit
		get_tree().quit()
