extends Button


func _on_pressed() -> void:
	
	#create dictionary for new layer's data, fill it with transperent and add it to the layers pane.
	var layer_meta = {
		"name": "Layer #" + str(%Layers.get_child_count()),
		"visible": true,
		"selected": true,
		"base_layer": false,
		"image": Image.create_empty(ProgramData.canvas_meta["size"].x,ProgramData.canvas_meta["size"].y,false,Image.FORMAT_RGBA8),
	}
	layer_meta["image"].fill(Color.TRANSPARENT)
	ProgramData.canvas_meta["layers"].append(layer_meta)
	
	var layer_i = preload("res://scenes/layer/layer.tscn").instantiate()
	%Layers.add_child(layer_i)
	layer_i.get_child(0).get_child(2).text = "Layer #" + str(%Layers.get_child_count())
	
	GlobalSignals.redraw_gui_nodes.emit()
