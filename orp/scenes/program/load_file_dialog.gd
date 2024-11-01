extends FileDialog



func _on_file_selected(path: String) -> void:
	var fa : FileAccess = FileAccess.open(path,FileAccess.READ)
	if fa != null:
		var json_data = JSON.parse_string(fa.get_line())
		ProgramData.canvas_meta.name = json_data["name"]
		ProgramData.canvas_meta.size = Vector2i(json_data["size"][0],json_data["size"][1])
		ProgramData.canvas_meta.color = Color(json_data["color"][0],json_data["color"][1],json_data["color"][2],json_data["color"][3])
		
		for l in json_data["layers"]:
			#I think i forgot to convert layer image to array when i programmed save function. so this is temporary parsing code until it is replaced inside save function.
			var parsed_layer_img_data_string : Array = l.image.replace('""',"").replace("[","").replace("]","").split(",")
			var parsed_layer_img_data_finished : Array
			for i in parsed_layer_img_data_string.size():
				parsed_layer_img_data_finished.append(int(parsed_layer_img_data_string[i]))
				
			var layer_load_data = {
				"name": l.name,
				"visible": l.visible,
				"selected": l.selected,
				"base_layer": l.base_layer,
				"image": Image.create_from_data(ProgramData.canvas_meta["size"].x,ProgramData.canvas_meta["size"].y,false,Image.FORMAT_RGBA8,parsed_layer_img_data_finished),
			}
			ProgramData.canvas_meta["layers"].append(layer_load_data)
			%Canvas_Texture.canvas_img = Image.create_empty(ProgramData.canvas_meta.size.x,ProgramData.canvas_meta.size.y,false,Image.FORMAT_RGBA8)
			%Canvas_Texture.canvas_img.fill(ProgramData.canvas_meta.color)
			%Canvas_Texture.texture = ImageTexture.create_from_image(%Canvas_Texture.canvas_img)
			%Canvas_Texture.pivot_offset = Vector2(size.x / 2.0,size.y / 2.0)
			%Canvas_Texture.scale = Vector2(clamp(%Canvas_Texture.scale.x + ProgramData.canvas_meta["zoom_level"],1,100),clamp(%Canvas_Texture.scale.y + ProgramData.canvas_meta["zoom_level"],1,100))
			%Canvas_Texture.custom_minimum_size = ProgramData.canvas_meta["size"] * ProgramData.canvas_meta["zoom_level"]
			%Canvas_Texture.material.set("shader_parameter/zoom_level",ProgramData.canvas_meta["zoom_level"])
			
			var layer_i = preload("res://scenes/layer/layer.tscn").instantiate()
			%Layers.add_child(layer_i)
			layer_i.get_child(0).get_child(2).text = l.name
			
		GlobalSignals.redraw_canvas.emit()
		GlobalSignals.enable_menu_options.emit()
		GlobalSignals.redraw_gui_nodes.emit()
		GlobalSignals.update_shaders.emit()
		
