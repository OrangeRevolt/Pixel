extends CenterContainer

func _ready() -> void:
	GlobalSignals.redraw_gui_nodes.connect(Callable(self,"_local_redraw"))
	if get_index() == 0:
		%Layer_Visible.disabled = true
		%Layer_Name.text = "Layer_Base"

func _local_redraw():
	queue_redraw()

func _draw() -> void:
	if ProgramData.canvas_meta["selected_layer"] == get_index():
		draw_rect(Rect2(Vector2(0,0),Vector2(size.x,size.y)),Color.ORANGE_RED,true)
