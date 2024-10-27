extends VBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalSignals.enable_menu_options.connect(Callable(self,"_enable_tools"))


func _enable_tools():
	%Pen.disabled = false
	%Eraser.disabled = false
	%Bucket.disabled = false
	%Primary_Color_Picker.disabled = false
	%Secondary_Color_Picker.disabled = false
	%Tip_Size_Slider.editable = true
	%Tip_Size_SpinBox.editable = true
