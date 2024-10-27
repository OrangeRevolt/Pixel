extends VBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalSignals.create_user_canvas.connect(Callable(self,"_create_base_layer"))
	


func _create_base_layer():
	#remove old data if there was a previous canvas made.
	for l in get_children():
		ProgramData.canvas_meta["layers"].pop_at(0)
		remove_child(l)
		l.queue_free()
	ProgramData.canvas_meta["selected_layer"] = 0
	
	#create dictionary for layer data, then fill it in to push it into the layers array. add a layer node to layers pane.
	var layer_meta = {
		"name": "Base_Layer",
		"visible": true,
		"selected": true,
		"base_layer": true,
		"image": Image.create_empty(ProgramData.canvas_meta["size"].x,ProgramData.canvas_meta["size"].y,false,Image.FORMAT_RGBA8),
	}
	layer_meta["image"].fill(ProgramData.canvas_meta["color"])
	ProgramData.canvas_meta["layers"].append(layer_meta)
	add_child(preload("res://scenes/layer/layer.tscn").instantiate())
