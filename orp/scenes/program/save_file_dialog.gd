extends FileDialog

#var canvas_meta = {
	#"name" : "New Canvas", #user canvas name
	#"size" : Vector2i(8,8), #user canvas size in pixels
	#"color" : Color.WHITE, #starting canvas fill color.
	#"layers" : [], #holds all the layer dictionaries.
	#"zoom_level" : 1, #zoom level of user canvas.
	#"selected_layer" : 0, #the current layer selected.
	#"selected_tool" : 0, #the current tool selected.
	#"tool_tip_size" : 1, #the size of the tool cursor texture.
	#"primary_color" : Color.BLACK, #the primary color of choosen by user. default black on start.
	#"secondary_color" : Color.WHITE, #the secondary color choosen by user. default white on start.
	#"grid" : false, #bool to show/hide the canvas grid, by way of the canvas shader.
	#"grid_cell_size" : Vector2i(1,1), #the size of each grid cell of the grid.
	#"grid_color" : Color.BLACK, #the color of the grid lines.
#}


func _on_file_selected(path: String) -> void:
	var fa : FileAccess = FileAccess.open(path,FileAccess.WRITE)
	#convert dictionary so storing in json works right (it cant convert vectors or colors..)
	if fa != null:
		var s_data = {
			"name": str(ProgramData.canvas_meta["name"]),
			"size": [int(ProgramData.canvas_meta["size"].x),int(ProgramData.canvas_meta["size"].y)],
			"color": [float(ProgramData.canvas_meta["color"].r),float(ProgramData.canvas_meta["color"].g),float(ProgramData.canvas_meta["color"].b),float(ProgramData.canvas_meta["color"].a)],
			"layers": [],
			"zoom_level": int(ProgramData.canvas_meta["zoom_level"]),
			"selected_tool": int(ProgramData.canvas_meta["selected_tool"]), #the current tool selected.
			"tool_tip_size": int(ProgramData.canvas_meta["tool_tip_size"]), #the size of the tool cursor texture.
			"primary_color": [float(ProgramData.canvas_meta["primary_color"].r),float(ProgramData.canvas_meta["primary_color"].g),float(ProgramData.canvas_meta["primary_color"].b),float(ProgramData.canvas_meta["primary_color"].a)], #the primary color of choosen by user. default black on start.
			"secondary_color": [float(ProgramData.canvas_meta["secondary_color"].r),float(ProgramData.canvas_meta["secondary_color"].g),float(ProgramData.canvas_meta["secondary_color"].b),float(ProgramData.canvas_meta["secondary_color"].a)], #the secondary color choosen by user. default white on start.
			"grid": bool(ProgramData.canvas_meta["grid"]), #bool to show/hide the canvas grid, by way of the canvas shader.
			"grid_cell_size": [ProgramData.canvas_meta["grid_cell_size"].x,ProgramData.canvas_meta["grid_cell_size"].y], #the size of each grid cell of the grid.
			"grid_color" : [float(ProgramData.canvas_meta["grid_color"].r),float(ProgramData.canvas_meta["grid_color"].g),float(ProgramData.canvas_meta["grid_color"].b),float(ProgramData.canvas_meta["grid_color"].a)], #the color of the grid lines.
		}
		for l in ProgramData.canvas_meta["layers"]:
			var layer_s_data = {
				"name": str(l.name),
				"visible": bool(l.visible),
				"selected": bool(l.selected),
				"base_layer": bool(l.base_layer),
				"image": l.image.get_data(),
			}
			s_data.layers.append(layer_s_data)
			
		var jsn_string = JSON.stringify(s_data,"",false,true)
		fa.store_line(jsn_string)
	fa.close()
