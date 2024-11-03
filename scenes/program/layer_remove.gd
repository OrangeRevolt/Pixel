extends Button



func _on_button_up() -> void:
	if ProgramData.canvas_meta["selected_layer"] - 1 > -1:
		for l in %Layers.get_children():
			if l.get_index() == ProgramData.canvas_meta["selected_layer"]:
				%Layers.remove_child(l)
				l.queue_free()
				break
		
		ProgramData.canvas_meta["layers"].pop_at(ProgramData.canvas_meta["selected_layer"])
		if %Canvas_Texture.image_history[0].layer == ProgramData.canvas_meta["selected_layer"]:
			print("history cleared for layer" + str(ProgramData.canvas_meta["selected_layer"]))
			%Canvas_Texture.image_history.clear()
			%Canvas_Texture.history_dex = 0
			GlobalSignals.enable_menu_options.emit()
			
		ProgramData.canvas_meta["selected_layer"] -= 1
		#print(ProgramData.canvas_meta["layers"])
		
	%Canvas_Texture._redraw_layers()
	GlobalSignals.redraw_gui_nodes.emit()
