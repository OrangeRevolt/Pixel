extends TextureRect

const REDRAW_PORTION = 0
const REDRAW_ALL = 1

const INPUT_ONE = 0
const INPUT_TWO = 1
var canvas_img : Image = Image.create_empty(8,8,false,Image.FORMAT_RGBA8)
var flood_fill_task_done = true #prevent user from clicking on canvas before bucket fill finishes.

#for undo/redo function
var image_history : Array = []
var tool_used : bool = false
var history_dex : int = 0
var in_undo : bool = false
var previous_layer : int = 0

#for mouse drag scrolling
var ms_vel : Vector2 = Vector2(-1,-1) #stores the motion velocity vector of the mouse.
var ms_last_pos : Vector2 = Vector2(-1,-1) #stores the starting drag postion, for distance based scrolling speed.

func _ready() -> void:
	GlobalSignals.popup_open.connect(Callable(self,"_disable_input"))
	GlobalSignals.popup_exited.connect(Callable(self,"_enable_input"))
	GlobalSignals.create_user_canvas.connect(Callable(self,"_create_canvas"))
	GlobalSignals.redraw_canvas.connect(Callable(self,"_redraw_layers"))
	GlobalSignals.update_shaders.connect(Callable(self,"_update_local_shaders"))
	GlobalSignals.resize_canvas.connect(Callable(self,"_resize_usercanvas"))
	GlobalSignals.flip_canvas_x.connect(Callable(self,"_flip_layer_x"))
	GlobalSignals.flip_canvas_y.connect(Callable(self,"_flip_layer_y"))
	GlobalSignals.undo.connect(Callable(self,"_undo_canvas_edit"))
	GlobalSignals.redo.connect(Callable(self,"_redo_canvas_edit"))

func _flip_layer_x():
	ProgramData.canvas_meta["layers"][ProgramData.canvas_meta["selected_layer"]].image.flip_x()
	_redraw_layers(REDRAW_ALL)


func _flip_layer_y():
	ProgramData.canvas_meta["layers"][ProgramData.canvas_meta["selected_layer"]].image.flip_y()
	_redraw_layers(REDRAW_ALL)


func _undo_canvas_edit(): 
	#since we add two canvas histories (old and new change) per edit, we need to subtract by two to get the undo history.
	history_dex = clamp(history_dex - 2, 0,image_history.size()-1)
	var h_image : Image = Image.create_from_data(ProgramData.canvas_meta["size"].x,ProgramData.canvas_meta["size"].y,false,Image.FORMAT_RGBA8,image_history[history_dex].image)
	ProgramData.canvas_meta["layers"][image_history[history_dex].layer].image = h_image
	print(str(history_dex),",",str(image_history.size()-1))
	_redraw_layers(REDRAW_ALL)
	if history_dex == 0:
		%Edit.set_item_disabled(2,true)
	else:
		%Edit.set_item_disabled(2,false)
		
	if image_history.size() > 0:
		%Edit.set_item_disabled(3,false)
		
func _redo_canvas_edit():
	#since we add two canvas histories (old and new change) per edit, we need to add by two to get the redo history.
	history_dex = clamp(history_dex + 2, 0,image_history.size()-1)
	var h_image : Image = Image.create_from_data(ProgramData.canvas_meta["size"].x,ProgramData.canvas_meta["size"].y,false,Image.FORMAT_RGBA8,image_history[history_dex].image)
	ProgramData.canvas_meta["layers"][image_history[history_dex].layer].image = h_image
	_redraw_layers(REDRAW_ALL)
	print(str(history_dex),",",str(image_history.size()-1))
	if history_dex >= image_history.size()-1:
		%Edit.set_item_disabled(3,true)
	else:
		%Edit.set_item_disabled(3,false)
		
	if image_history.size() > 0:
		%Edit.set_item_disabled(2,false)
		
func _disable_input():
	set_process_input(false)
	set_process(false)


func _enable_input():
	set_process_input(true)
	set_process(true)

func _update_local_shaders():
	
	material.set("shader_parameter/show_grid",ProgramData.canvas_meta["grid"])
	material.set("shader_parameter/zoom_level",ProgramData.canvas_meta["zoom_level"])
	material.set("shader_parameter/grid_cell_size",ProgramData.canvas_meta["grid_cell_size"])
	material.set("shader_parameter/grid_color",ProgramData.canvas_meta["grid_color"])


func _create_canvas():
	material.set("shader_parameter/show_grid",ProgramData.canvas_meta["grid"])
	material.set("shader_parameter/zoom_level",1)
	material.set("shader_parameter/grid_cell_size",Vector2i(1,1))
	ProgramData.canvas_meta["zoom_level"] = 1
	canvas_img.resize(ProgramData.canvas_meta["size"].x * ProgramData.canvas_meta["zoom_level"],ProgramData.canvas_meta["size"].y * ProgramData.canvas_meta["zoom_level"],Image.INTERPOLATE_NEAREST)
	canvas_img.fill(ProgramData.canvas_meta["color"])
	texture = ImageTexture.create_from_image(canvas_img)
	

func _resize_usercanvas():
	
	canvas_img.resize(ProgramData.canvas_meta["size"].x,ProgramData.canvas_meta["size"].y,Image.INTERPOLATE_NEAREST)
	canvas_img.fill(ProgramData.canvas_meta["color"])
	
	for l in ProgramData.canvas_meta["layers"]:
		#create a new image to resize layers
		var rimg : Image = Image.create_empty(ProgramData.canvas_meta["size"].x,ProgramData.canvas_meta["size"].y,false,Image.FORMAT_RGBA8)
		#copy over the old image to the new resized image, top-left. (change this in version 2.0 so to allow the user to change where the old image will be ancored(top-left,top,top-right,bottom-right,bottom,bottom-right) if new image is larger then the layer size
		rimg.blit_rect(l.image,Rect2i(Vector2i(0,0),Vector2i(l.image.get_width(),l.image.get_height())),Vector2i(0,0))
		l.image = rimg
		if l.visible == true:
			for y in l.image.get_width():
				for x in l.image.get_height():
					if l.image.get_pixelv(Vector2i(x,y)) != Color.TRANSPARENT:
						canvas_img.set_pixelv(Vector2i(x,y),l.image.get_pixelv(Vector2i(x,y)))
		
	texture = ImageTexture.create_from_image(canvas_img)
	pivot_offset = Vector2(size.x / 2,size.y / 2)
	scale = Vector2(ProgramData.canvas_meta["zoom_level"],ProgramData.canvas_meta["zoom_level"])
	custom_minimum_size = ProgramData.canvas_meta["size"] * ProgramData.canvas_meta["zoom_level"]
	
func _mouse_in_canvas(pos : Vector2):
	if pos.x > -1 and pos.y > -1 and pos.x < ProgramData.canvas_meta["size"].x * ProgramData.canvas_meta["zoom_level"] and pos.y < ProgramData.canvas_meta["size"].y  * ProgramData.canvas_meta["zoom_level"]:
		return true
	else:
		return false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		ms_vel = event.screen_velocity
	else:
		ms_vel = Vector2.ZERO

func _process(_delta: float) -> void:
	#we need to continously redraw every frame, so the tool tip texture can be seen on the canvas or not if position is outside.
	queue_redraw()
	#store the last mouse position for the drag canvas function.
	if Input.is_action_just_pressed("Grab_Scolling"):
		ms_last_pos = get_global_mouse_position()
	#drag the canvas by the distance to the starting drag point.
	if Input.is_action_pressed("Grab_Scolling") and (%Canvas_Scroll.get_h_scroll_bar().visible or %Canvas_Scroll.get_v_scroll_bar().visible) and _mouse_in_canvas(get_local_mouse_position()) == true:
		mouse_default_cursor_shape = CursorShape.CURSOR_DRAG
		if ms_vel.y < 0:
			%Canvas_Scroll.scroll_vertical -= 1 * ms_last_pos.distance_to(get_global_mouse_position()) * 0.1
		elif ms_vel.y > 0:
			%Canvas_Scroll.scroll_vertical += 1 * ms_last_pos.distance_to(get_global_mouse_position()) * 0.1
		if ms_vel.x < 0:
			%Canvas_Scroll.scroll_horizontal -= 1 * ms_last_pos.distance_to(get_global_mouse_position()) * 0.1
		elif ms_vel.x > 0:
			%Canvas_Scroll.scroll_horizontal += 1 * ms_last_pos.distance_to(get_global_mouse_position()) * 0.1
	else:
		ms_vel = Vector2.ZERO
	
	if Input.is_action_just_released("Tool_Input_One") and tool_used == true:
		if image_history.size() > 0:
			#check to see if we are before the last history canvas, if so that means we need to delete the old redo history.
			var old_h_size = image_history.size()-1
			if history_dex < image_history.size()-1:
				for i in old_h_size - history_dex:
					image_history.pop_back()
					
			add_history(ProgramData.canvas_meta["layers"][ProgramData.canvas_meta["selected_layer"]],ProgramData.canvas_meta["selected_layer"])
			
		in_undo = false
		tool_used = false
		
	if Input.is_action_just_pressed("Zoom_In") and ProgramData.canvas_meta["layers"].size() > 0:
		
		ProgramData.canvas_meta["zoom_level"] = clamp(ProgramData.canvas_meta["zoom_level"] + 1,1,99)
		#to keep the canvas is in the center of the screen, we need to update the offset and set custom min size so the scroll container works right.
		pivot_offset = Vector2(size.x / 2,size.y / 2)
		#prevent scale values to exceed limits.
		scale = Vector2(clamp(scale.x + ProgramData.canvas_meta["zoom_level"],1,100),clamp(scale.y + ProgramData.canvas_meta["zoom_level"],1,100))
		custom_minimum_size = ProgramData.canvas_meta["size"] * ProgramData.canvas_meta["zoom_level"]
		#update our canvas shader, so the grid scales to our zoom.
		material.set("shader_parameter/zoom_level",ProgramData.canvas_meta["zoom_level"])
		GlobalSignals.update_shaders.emit()
			
	elif Input.is_action_just_pressed("Zoom_Out") and ProgramData.canvas_meta["layers"].size() > 0:
		
		ProgramData.canvas_meta["zoom_level"] = clamp(ProgramData.canvas_meta["zoom_level"] - 1,1,99)
		pivot_offset = Vector2(size.x / 2,size.y / 2)
		scale = Vector2(clamp(scale.x - ProgramData.canvas_meta["zoom_level"],1,100),clamp(scale.y - ProgramData.canvas_meta["zoom_level"],1,100))
		custom_minimum_size = ProgramData.canvas_meta["size"] * ProgramData.canvas_meta["zoom_level"]
		material.set("shader_parameter/zoom_level",ProgramData.canvas_meta["zoom_level"])
		
		GlobalSignals.update_shaders.emit()
	
	if Input.is_action_just_pressed("Tool_Color_Sample") and ProgramData.canvas_meta["layers"].size() > 0 and _mouse_in_canvas(get_local_mouse_position()) == true:
		
		var snap_ms_pos : Vector2i = Vector2i(int(floor(get_local_mouse_position().x / ((ProgramData.canvas_meta["size"].x * ProgramData.canvas_meta["zoom_level"]) / ProgramData.canvas_meta["size"].x))), int(floor(get_local_mouse_position().y / ((ProgramData.canvas_meta["size"].y * ProgramData.canvas_meta["zoom_level"]) / ProgramData.canvas_meta["size"].y))))
		ProgramData.canvas_meta["primary_color"] = ProgramData.canvas_meta["layers"][ProgramData.canvas_meta["selected_layer"]].image.get_pixelv(snap_ms_pos)
		%Primary_Color_Picker.color = ProgramData.canvas_meta["primary_color"]
	
	
	if Input.is_action_pressed("Tool_Input_One") and ProgramData.canvas_meta["layers"].size() > 0:
		
		if ProgramData.canvas_meta["selected_tool"] == ProgramData.PEN_TOOL and _mouse_in_canvas(get_local_mouse_position()) == true:
			#add a history to the undo, when just pressed so it just adds one entry.
			if in_undo == false:
				
				add_history(ProgramData.canvas_meta["layers"][ProgramData.canvas_meta["selected_layer"]],ProgramData.canvas_meta["selected_layer"])
				GlobalSignals.enable_menu_options.emit()
				in_undo = true
				
			pen(INPUT_ONE)
			
		elif ProgramData.canvas_meta["selected_tool"] == ProgramData.ERASER_TOOL and _mouse_in_canvas(get_local_mouse_position()) == true:
			if in_undo == false:
				
				add_history(ProgramData.canvas_meta["layers"][ProgramData.canvas_meta["selected_layer"]],ProgramData.canvas_meta["selected_layer"])
				GlobalSignals.enable_menu_options.emit()
				in_undo = true
				
			eraser(INPUT_ONE)
		
	elif Input.is_action_pressed("Tool_Input_Two") and ProgramData.canvas_meta["layers"].size() > 0:
		
		if ProgramData.canvas_meta["selected_tool"] == ProgramData.PEN_TOOL and _mouse_in_canvas(get_local_mouse_position()) == true:
			if in_undo == false:
				
				add_history(ProgramData.canvas_meta["layers"][ProgramData.canvas_meta["selected_layer"]],ProgramData.canvas_meta["selected_layer"])
				GlobalSignals.enable_menu_options.emit()
				in_undo = true
				
			pen(INPUT_TWO)
	
	
	if Input.is_action_just_pressed("Tool_Input_One") and ProgramData.canvas_meta["layers"].size() > 0 and flood_fill_task_done == true:
		if ProgramData.canvas_meta["selected_tool"] == ProgramData.BUCKET_TOOL and _mouse_in_canvas(get_local_mouse_position()) == true:
			if in_undo == false:
				
				add_history(ProgramData.canvas_meta["layers"][ProgramData.canvas_meta["selected_layer"]],ProgramData.canvas_meta["selected_layer"])
				GlobalSignals.enable_menu_options.emit()
				in_undo = true
			flood_fill_task_done = false
			bucket(INPUT_ONE)
			
	elif Input.is_action_just_pressed("Tool_Input_Two") and ProgramData.canvas_meta["layers"].size() > 0 and flood_fill_task_done == true:
		if ProgramData.canvas_meta["selected_tool"] == ProgramData.BUCKET_TOOL and _mouse_in_canvas(get_local_mouse_position()) == true:
			if in_undo == false:
				
				add_history(ProgramData.canvas_meta["layers"][ProgramData.canvas_meta["selected_layer"]],ProgramData.canvas_meta["selected_layer"])
				GlobalSignals.enable_menu_options.emit()
				in_undo = true
			flood_fill_task_done = false
			bucket(INPUT_TWO)
	
	if Input.is_action_just_pressed("Tool_Tip_Increase") and ProgramData.canvas_meta["layers"].size() > 0:
		ProgramData.canvas_meta["tool_tip_size"] = clamp(ProgramData.canvas_meta["tool_tip_size"] + 1, 1, 100)
		%Tip_Size_Slider.value = ProgramData.canvas_meta["tool_tip_size"]
		%Tip_Size_SpinBox.value = ProgramData.canvas_meta["tool_tip_size"]
		
	elif Input.is_action_just_pressed("Tool_Tip_Decrease") and ProgramData.canvas_meta["layers"].size() > 0:
		ProgramData.canvas_meta["tool_tip_size"] = clamp(ProgramData.canvas_meta["tool_tip_size"] - 1, 1, 100)
		%Tip_Size_Slider.value = ProgramData.canvas_meta["tool_tip_size"]
		%Tip_Size_SpinBox.value = ProgramData.canvas_meta["tool_tip_size"]
		
	if Input.is_action_just_pressed("Pen_Tool"):
		ProgramData.canvas_meta["selected_tool"] = ProgramData.PEN_TOOL
	elif Input.is_action_just_pressed("Eraser_Tool"):
		ProgramData.canvas_meta["selected_tool"] = ProgramData.ERASER_TOOL
	elif Input.is_action_just_pressed("Bucket_Tool"):
		ProgramData.canvas_meta["selected_tool"] = ProgramData.BUCKET_TOOL

func _redraw_layers(redraw_type : int = 1):
	
	#recopy the layers to canvas img if they are visible.
	
	#do perportion math to get the correct position of the mouse, respecting the true size in ProgramData.
	var snap_ms_pos : Vector2i = Vector2i(int(floor(get_local_mouse_position().x / ((ProgramData.canvas_meta["size"].x * ProgramData.canvas_meta["zoom_level"]) / ProgramData.canvas_meta["size"].x))), int(floor(get_local_mouse_position().y / ((ProgramData.canvas_meta["size"].y * ProgramData.canvas_meta["zoom_level"]) / ProgramData.canvas_meta["size"].y))))
	
	canvas_img.resize(ProgramData.canvas_meta["size"].x,ProgramData.canvas_meta["size"].y,Image.INTERPOLATE_NEAREST)
	
	#only one pixel changed so we only copy one pixel without the need to check for transperency.
	if redraw_type == REDRAW_PORTION:
		
		for l in ProgramData.canvas_meta["layers"]:
			if ProgramData.canvas_meta["selected_tool"] == ProgramData.PEN_TOOL:
				if l.visible == true:
					canvas_img.blit_rect(l.image,Rect2i(Vector2i(snap_ms_pos.x,snap_ms_pos.y),Vector2i(ProgramData.canvas_meta["tool_tip_size"],ProgramData.canvas_meta["tool_tip_size"])),Vector2i(snap_ms_pos.x,snap_ms_pos.y))
					
	#more than one pixel changed, so we need to update all layers. (this is slow..not sure what to improve, cause i need to prevent transperency removing the previous layers pixels.)
	elif redraw_type == REDRAW_ALL:
		
		canvas_img.fill(ProgramData.canvas_meta["color"])
		var sample_pixel_color : Color
		for l in ProgramData.canvas_meta["layers"]:
			if l.visible == true:
				for py in l.image.get_width():
					for px in l.image.get_height():
						sample_pixel_color = l.image.get_pixelv(Vector2i(px,py))
						if sample_pixel_color != Color.TRANSPARENT:
							canvas_img.set_pixelv(Vector2i(px,py),sample_pixel_color)
	
	RenderingServer.texture_2d_update(texture.get_rid(),canvas_img,0)

func add_history(layer : Dictionary, layer_dex : int):
	#because the way undo/redo works, we to clear out history if we on a new layer.
	if previous_layer != layer_dex:
		image_history.clear()
		history_dex = 0
	
	previous_layer = layer_dex
	var img_hist = {
		"layer": layer_dex,
		"image": layer.image.get_data(),
	}
	image_history.push_back(img_hist)
	history_dex += 1


func pen(action_type) -> void:
	
	#do perportion math to get the correct position of the mouse, respecting the true size in ProgramData.
	var snap_ms_pos : Vector2i = Vector2i(int(floor(get_local_mouse_position().x / ((ProgramData.canvas_meta["size"].x * ProgramData.canvas_meta["zoom_level"]) / ProgramData.canvas_meta["size"].x))), int(floor(get_local_mouse_position().y / ((ProgramData.canvas_meta["size"].y * ProgramData.canvas_meta["zoom_level"]) / ProgramData.canvas_meta["size"].y))))
	var sample_color = ProgramData.canvas_meta["layers"][ProgramData.canvas_meta["selected_layer"]].image.get_pixelv(snap_ms_pos)
	var cur_layer = ProgramData.canvas_meta["layers"][ProgramData.canvas_meta["selected_layer"]]
	if action_type == INPUT_ONE:
		for py in ProgramData.canvas_meta["tool_tip_size"]:
			for px in ProgramData.canvas_meta["tool_tip_size"]:
				if (snap_ms_pos.x + px < cur_layer.image.get_width() and snap_ms_pos.y + py < cur_layer.image.get_height()):
					sample_color = ProgramData.canvas_meta["layers"][ProgramData.canvas_meta["selected_layer"]].image.get_pixelv(Vector2i(snap_ms_pos.x + px, snap_ms_pos.y + py))
					if sample_color != ProgramData.canvas_meta["primary_color"]:
						cur_layer.image.set_pixelv(Vector2i(snap_ms_pos.x + px,snap_ms_pos.y + py),ProgramData.canvas_meta["primary_color"])
		_redraw_layers(REDRAW_PORTION)
		tool_used = true
			
	elif action_type == INPUT_TWO:
		for py in ProgramData.canvas_meta["tool_tip_size"]:
			for px in ProgramData.canvas_meta["tool_tip_size"]:
				if (snap_ms_pos.x + px < cur_layer.image.get_width() and snap_ms_pos.y + py < cur_layer.image.get_height()):
					if sample_color != ProgramData.canvas_meta["secondary_color"]:
						cur_layer.image.set_pixelv(Vector2i(snap_ms_pos.x + px,snap_ms_pos.y + py),ProgramData.canvas_meta["secondary_color"])
		_redraw_layers(REDRAW_PORTION)
		tool_used = true

func eraser(action_type) -> void:
	#eraser works the same way as pen, but draws with transperency on layers above base layer.
	var snap_ms_pos : Vector2i = Vector2i(int(floor(get_local_mouse_position().x / ((ProgramData.canvas_meta["size"].x * ProgramData.canvas_meta["zoom_level"]) / ProgramData.canvas_meta["size"].x))), int(floor(get_local_mouse_position().y / ((ProgramData.canvas_meta["size"].y * ProgramData.canvas_meta["zoom_level"]) / ProgramData.canvas_meta["size"].y))))
	var sample_color = ProgramData.canvas_meta["layers"][ProgramData.canvas_meta["selected_layer"]].image.get_pixelv(snap_ms_pos)
	var cur_layer = ProgramData.canvas_meta["layers"][ProgramData.canvas_meta["selected_layer"]]
	
	if action_type == INPUT_ONE:
		
		if ProgramData.canvas_meta["selected_layer"] < 1:
			
			for py in ProgramData.canvas_meta["tool_tip_size"]:
				for px in ProgramData.canvas_meta["tool_tip_size"]:
					
					if (snap_ms_pos.x + px < cur_layer.image.get_width() and snap_ms_pos.y + py < cur_layer.image.get_height()):
						sample_color = ProgramData.canvas_meta["layers"][ProgramData.canvas_meta["selected_layer"]].image.get_pixelv(Vector2i(snap_ms_pos.x + px, snap_ms_pos.y + py))
						if sample_color != ProgramData.canvas_meta["secondary_color"]:
							cur_layer.image.set_pixelv(Vector2i(snap_ms_pos.x + px,snap_ms_pos.y + py),ProgramData.canvas_meta["secondary_color"])
			_redraw_layers(REDRAW_ALL)
			tool_used = true
		else:
			for py in ProgramData.canvas_meta["tool_tip_size"]:
				for px in ProgramData.canvas_meta["tool_tip_size"]:
					if (snap_ms_pos.x + px < cur_layer.image.get_width() and snap_ms_pos.y + py < cur_layer.image.get_height()):
						cur_layer.image.set_pixelv(Vector2i(snap_ms_pos.x + px,snap_ms_pos.y + py),Color.TRANSPARENT)
			_redraw_layers(REDRAW_ALL)
			tool_used = true

func layer_img_is_one_color(layer_dex):
	var first_color : Array = [ProgramData.canvas_meta["layers"][layer_dex].image.get_data()[0],ProgramData.canvas_meta["layers"][layer_dex].image.get_data()[1],ProgramData.canvas_meta["layers"][layer_dex].image.get_data()[2],ProgramData.canvas_meta["layers"][layer_dex].image.get_data()[3]]
	for x in ProgramData.canvas_meta["layers"][layer_dex].image.get_data().size() / 4:
		if x > 0:
			if ProgramData.canvas_meta["layers"][layer_dex].image.get_data()[x * 4] != first_color[0] or ProgramData.canvas_meta["layers"][layer_dex].image.get_data()[(x * 4) + 1] != first_color[1] or ProgramData.canvas_meta["layers"][layer_dex].image.get_data()[(x * 4) + 2] != first_color[2] or ProgramData.canvas_meta["layers"][layer_dex].image.get_data()[(x * 4) + 3] != first_color[3]:
				return false
	return true
	

func bucket(action_type) -> void:
	
	
	#We use a flood-fill algorithm to fill the canvas, by checking the current pixels neighbors (x - 1, y - 1, x + 1, y + 1) until we run out pixels to fill or run into a different color from sample.
	
	#que_fill will hold the pixels that need to be checked to fill.
	var que_fill : Array = []
	#Do perportion math to get the correct position of the mouse, respecting the true size in ProgramData.
	var snap_ms_pos : Vector2i = Vector2i(int(floor(get_local_mouse_position().x / ((ProgramData.canvas_meta["size"].x * ProgramData.canvas_meta["zoom_level"]) / ProgramData.canvas_meta["size"].x))), int(floor(get_local_mouse_position().y / ((ProgramData.canvas_meta["size"].y * ProgramData.canvas_meta["zoom_level"]) / ProgramData.canvas_meta["size"].y))))
	#Grab the sample color on the canvas, where the mouse position is.
	var sample_pixel : Color = ProgramData.canvas_meta["layers"][ProgramData.canvas_meta["selected_layer"]].image.get_pixelv(snap_ms_pos)
	
	
	#Dont fill if the sample is the same as the primary or secondary color.
	if (action_type == INPUT_ONE and sample_pixel != ProgramData.canvas_meta["primary_color"]) or (action_type == INPUT_TWO and sample_pixel != ProgramData.canvas_meta["secondary_color"]):
		
		#if image is filled with one color, than just fill it using the image.fill because it's faster.
		if layer_img_is_one_color(ProgramData.canvas_meta["selected_layer"]) == true:
			if action_type == INPUT_ONE:
				ProgramData.canvas_meta["layers"][ProgramData.canvas_meta["selected_layer"]].image.fill(ProgramData.canvas_meta["primary_color"])
			elif action_type == INPUT_TWO:
				ProgramData.canvas_meta["layers"][ProgramData.canvas_meta["selected_layer"]].image.fill(ProgramData.canvas_meta["secondary_color"])
			_redraw_layers(REDRAW_ALL)
			return
			
		else:
			#create que pixel data, to add first pixel to check in while loop.
			var que_pixel = {
				"pos": snap_ms_pos,
				"color": ProgramData.canvas_meta["primary_color"],
			}
			if action_type == INPUT_ONE:
				que_pixel.color = ProgramData.canvas_meta["primary_color"]
			elif action_type == INPUT_TWO:
				que_pixel.color = ProgramData.canvas_meta["secondary_color"]
				
			
			que_fill.push_back(que_pixel)
			ProgramData.canvas_meta["layers"][ProgramData.canvas_meta["selected_layer"]].image.set_pixelv(que_pixel.pos,que_pixel.color)
			
			#Keep checking until the que_fill is empty.
			while que_fill.size() > 0:
				#Check the qued pixel's neighbor pixels to add to que.
				if que_fill[0].pos.x + 1 < ProgramData.canvas_meta["layers"][ProgramData.canvas_meta["selected_layer"]].image.get_width():
					var que_pixel_right = {
						"pos": Vector2i(que_fill[0].pos.x + 1,que_fill[0].pos.y),
						"color": que_fill[0].color,
					}
					if ProgramData.canvas_meta["layers"][ProgramData.canvas_meta["selected_layer"]].image.get_pixelv(Vector2i(que_fill[0].pos.x + 1,que_fill[0].pos.y)) == sample_pixel:
						ProgramData.canvas_meta["layers"][ProgramData.canvas_meta["selected_layer"]].image.set_pixelv(Vector2i(que_fill[0].pos.x + 1,que_fill[0].pos.y),que_pixel_right.color)
						que_fill.push_back(que_pixel_right)
						
				if que_fill[0].pos.x - 1 > -1:
					var que_pixel_left = {
						"pos": Vector2i(que_fill[0].pos.x - 1,que_fill[0].pos.y),
						"color": que_fill[0].color,
					}
					if ProgramData.canvas_meta["layers"][ProgramData.canvas_meta["selected_layer"]].image.get_pixelv(Vector2i(que_fill[0].pos.x - 1,que_fill[0].pos.y)) == sample_pixel:
						ProgramData.canvas_meta["layers"][ProgramData.canvas_meta["selected_layer"]].image.set_pixelv(Vector2i(que_fill[0].pos.x - 1,que_fill[0].pos.y),que_pixel_left.color)
						que_fill.push_back(que_pixel_left)
						
				if que_fill[0].pos.y + 1 < ProgramData.canvas_meta["layers"][ProgramData.canvas_meta["selected_layer"]].image.get_height():
					var que_pixel_down = {
						"pos": Vector2i(que_fill[0].pos.x,que_fill[0].pos.y + 1),
						"color": que_fill[0].color,
					}
					if ProgramData.canvas_meta["layers"][ProgramData.canvas_meta["selected_layer"]].image.get_pixelv(Vector2i(que_fill[0].pos.x,que_fill[0].pos.y + 1)) == sample_pixel:
						ProgramData.canvas_meta["layers"][ProgramData.canvas_meta["selected_layer"]].image.set_pixelv(Vector2i(que_fill[0].pos.x,que_fill[0].pos.y + 1),que_pixel_down.color)
						que_fill.push_back(que_pixel_down)
						
				if que_fill[0].pos.y - 1 > -1:
					var que_pixel_up = {
						"pos": Vector2i(que_fill[0].pos.x,que_fill[0].pos.y - 1),
						"color": que_fill[0].color,
					}
					if ProgramData.canvas_meta["layers"][ProgramData.canvas_meta["selected_layer"]].image.get_pixelv(Vector2i(que_fill[0].pos.x,que_fill[0].pos.y - 1)) == sample_pixel:
						ProgramData.canvas_meta["layers"][ProgramData.canvas_meta["selected_layer"]].image.set_pixelv(Vector2i(que_fill[0].pos.x,que_fill[0].pos.y - 1),que_pixel_up.color)
						que_fill.push_back(que_pixel_up)
					
				#remove first in que, because we are finished with that pixel.
				que_fill.pop_front()
			
			_redraw_layers(REDRAW_ALL)
			tool_used = true
			flood_fill_task_done = true

func _draw() -> void:
	#we use the original perportion math for the color we need to sample. Make sure to clamp the values so they are not beyond the canvas.
	var sample_ms_pos_x : int = clamp(int(floor(get_local_mouse_position().x / ((ProgramData.canvas_meta["size"].x * ProgramData.canvas_meta["zoom_level"]) / ProgramData.canvas_meta["size"].x))),0,ProgramData.canvas_meta["size"].x-1)
	var sample_ms_pos_y : int = clamp(int(floor(get_local_mouse_position().y / ((ProgramData.canvas_meta["size"].y * ProgramData.canvas_meta["zoom_level"]) / ProgramData.canvas_meta["size"].y))),0,ProgramData.canvas_meta["size"].y-1)
	var sample_ms_pos : Vector2i = Vector2i(sample_ms_pos_x, sample_ms_pos_y)
	
	if _mouse_in_canvas(sample_ms_pos) and ProgramData.canvas_meta["layers"].size() > 0:
		#slight change to perportion, cause we need to scale the zoom level.
		var snap_ms_pos : Vector2i = Vector2i(int(floor(get_local_mouse_position().x / ((ProgramData.canvas_meta["size"].x * ProgramData.canvas_meta["zoom_level"]) / ProgramData.canvas_meta["size"].x))) * ProgramData.canvas_meta["zoom_level"], int(floor(get_local_mouse_position().y / ((ProgramData.canvas_meta["size"].y * ProgramData.canvas_meta["zoom_level"]) / ProgramData.canvas_meta["size"].y))) * ProgramData.canvas_meta["zoom_level"] )
		var sample_pixel : Color = canvas_img.get_pixelv(sample_ms_pos)
		#we invert the sample color values so we can still see the tip texture no matter what color is on canvas.
		var invert_color : Color = Color(1.0 - sample_pixel.r, 1.0 - sample_pixel.g, 1.0 - sample_pixel.b, 1.0)
		#draw representation of the tool tip texture.
		draw_rect(Rect2(snap_ms_pos,Vector2(ProgramData.canvas_meta["tool_tip_size"] * ProgramData.canvas_meta["zoom_level"],ProgramData.canvas_meta["tool_tip_size"] * ProgramData.canvas_meta["zoom_level"])),invert_color,false,0.5,true)

func _exit_tree() -> void:
	pass
	#bucket_thread.free()
