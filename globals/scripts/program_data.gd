extends Node


const PEN_TOOL = 0
const ERASER_TOOL = 1
const BUCKET_TOOL = 2

const REDRAW_PORTION = 0
const REDRAW_ALL = 1

var canvas_meta = {
	"name" : "New Canvas",
	"size" : Vector2i(8,8),
	"color" : Color.WHITE,
	"layers" : [],
	"zoom_level" : 1,
	"selected_layer" : 0,
	"selected_tool" : 0,
	"primary_color" : Color.BLACK,
	"secondary_color" : Color.WHITE,
	"grid" : false,
	"grid_cell_size" : Vector2i(1,1),
	"grid_color" : Color.BLACK,
}
