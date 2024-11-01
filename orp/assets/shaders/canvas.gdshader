shader_type canvas_item;
//render_mode blend_mix;

//uniform sampler2D canvas_texture;

varying float v_x_pos;
varying float v_y_pos;

uniform bool show_grid = true;
uniform int zoom_level = 1;
uniform ivec2 grid_cell_size = ivec2(1,1);
uniform vec4 grid_color = vec4(0,0,0,1);

void vertex(){
	v_x_pos = VERTEX.x;
	v_y_pos = VERTEX.y;
}

void fragment() {
	vec4 tex_read = texture(TEXTURE,UV);
	
	
	if (show_grid == true){
		
		if (int(v_x_pos) % (zoom_level * grid_cell_size.x) == 0 || int(v_y_pos) % (zoom_level * grid_cell_size.y) == 0){
			COLOR = grid_color;
		}else
		{
			COLOR = tex_read;
		}
		
	}
}
