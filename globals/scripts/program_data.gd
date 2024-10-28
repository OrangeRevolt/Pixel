extends Node

#tool contants
const PEN_TOOL = 0
const ERASER_TOOL = 1
const BUCKET_TOOL = 2


#holds all the important info for saving later when saving out as .orp format (JSON)
#layers will be saved out by it's image data, and reloaded with new image nodes.

var canvas_meta = {
	"name" : "New Canvas", #user canvas name
	"size" : Vector2i(8,8), #user canvas size in pixels
	"color" : Color.WHITE, #starting canvas fill color.
	"layers" : [], #holds all the layer dictionaries.
	"zoom_level" : 1, #zoom level of user canvas.
	"selected_layer" : 0, #the current layer selected.
	"selected_tool" : 0, #the current tool selected.
	"tool_tip_size" : 1, #the size of the tool cursor texture.
	"primary_color" : Color.BLACK, #the primary color of choosen by user. default black on start.
	"secondary_color" : Color.WHITE, #the secondary color choosen by user. default white on start.
	"grid" : false, #bool to show/hide the canvas grid, by way of the canvas shader.
	"grid_cell_size" : Vector2i(1,1), #the size of each grid cell of the grid.
	"grid_color" : Color.BLACK, #the color of the grid lines.
}
