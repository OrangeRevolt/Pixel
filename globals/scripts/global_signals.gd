extends Node

@warning_ignore("unused_signal")
signal popup_exited
@warning_ignore("unused_signal")
signal create_user_canvas
@warning_ignore("unused_signal")
signal enable_menu_options #to turn on menu options that are disabled inititally pre-canvas creation. 
@warning_ignore("unused_signal")
signal redraw_canvas
@warning_ignore("unused_signal")
signal resize_canvas #used by texturerect to resize the canvas.
@warning_ignore("unused_signal")
signal redraw_gui_nodes #to call a gui node's _draw function that uses this signal.
@warning_ignore("unused_signal")
signal update_shaders #general signal to update shaders for nodes that use this signal.
