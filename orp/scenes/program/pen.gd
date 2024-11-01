extends Button

func _ready() -> void:
	GlobalSignals.redraw_gui_nodes.connect(Callable(self,"_update_button_theme"))

func _update_button_theme():
	if ProgramData.canvas_meta["selected_tool"] == ProgramData.PEN_TOOL:
		var bsl : StyleBoxFlat = StyleBoxFlat.new()
		bsl.bg_color = Color.ORANGE_RED
		bsl.set_corner_radius_all(4)
		add_theme_color_override("icon_normal_color",Color.BLACK)
		add_theme_color_override("icon_focus_color",Color.BLACK)
		add_theme_color_override("icon_hover_color",Color.BLACK)
		add_theme_stylebox_override("normal",bsl)
		add_theme_stylebox_override("focus",bsl)
	else:
		remove_theme_stylebox_override("normal")
		remove_theme_color_override("icon_normal_color")
		remove_theme_color_override("icon_focus_color")
		remove_theme_color_override("icon_hover_color")

func _on_pressed() -> void:
	ProgramData.canvas_meta["selected_tool"] = ProgramData.PEN_TOOL
	%Tip_Size_Slider.editable = true
	%Tip_Size_SpinBox.editable = true
	GlobalSignals.redraw_gui_nodes.emit()
	