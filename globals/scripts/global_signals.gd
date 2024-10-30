extends Node

#we are using these signals, so we add ingore warnings that occur cause gd script doesn't see outside scope.
@warning_ignore("unused_signal")
signal popup_open #to prevent unwanted node input when a popup is open
@warning_ignore("unused_signal")
signal popup_exited #to enable node input when a popup is closed.
@warning_ignore("unused_signal")
signal create_user_canvas #calls all nodes that are needed to initiate when the canvas is created.
@warning_ignore("unused_signal")
signal enable_menu_options #to turn on menu options that are disabled inititally pre-canvas creation. 
@warning_ignore("unused_signal")
signal redraw_canvas #to call canvas redrawing globally.
@warning_ignore("unused_signal")
signal resize_canvas #to call canvas resize globally.
@warning_ignore("unused_signal")
signal redraw_gui_nodes #to call a gui node's _draw function or themes that uses this signal.
@warning_ignore("unused_signal")
signal update_shaders #global signal to update node shaders.
