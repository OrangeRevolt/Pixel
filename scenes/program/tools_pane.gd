extends VBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalSignals.enable_menu_options.connect(Callable(self,"_enable_tools"))
	GlobalSignals.redraw_gui_nodes.connect(Callable(self,"redraw_tools"))


func _redraw_tools():
	if ProgramData.canvas_meta["selected_tool"] == ProgramData.PEN_TOOL:
		%Pen.button_pressed = true
		%Pen.grab_focus()
	%Eraser.disabled = false
	if ProgramData.canvas_meta["selected_tool"] == ProgramData.ERASER_TOOL:
		%Eraser.button_pressed = true
		%Eraser.grab_focus()
	%Bucket.disabled = false
	if ProgramData.canvas_meta["selected_tool"] == ProgramData.ERASER_TOOL:
		%Bucket.button_pressed = true
		%Bucket.grab_focus()


func _enable_tools():
	%Pen.disabled = false
	if ProgramData.canvas_meta["selected_tool"] == ProgramData.PEN_TOOL:
		%Pen.button_pressed = true
		%Pen.grab_focus()
	%Eraser.disabled = false
	if ProgramData.canvas_meta["selected_tool"] == ProgramData.ERASER_TOOL:
		%Eraser.button_pressed = true
		%Eraser.grab_focus()
	%Bucket.disabled = false
	if ProgramData.canvas_meta["selected_tool"] == ProgramData.ERASER_TOOL:
		%Bucket.button_pressed = true
		%Bucket.grab_focus()
	%Primary_Color_Picker.disabled = false
	%Secondary_Color_Picker.disabled = false
	%Tip_Size_Slider.editable = true
	%Tip_Size_SpinBox.editable = true
