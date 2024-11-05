using Godot;
using Godot.Collections;
using System;
using System.Collections.Generic;
using System.Linq;

public partial class imgProc : Node2D
{
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
	}


	public void Bucket(int actType,Godot.Collections.Dictionary canvasMeta,Vector2 locMsPos)
	{
		
		List<Godot.Collections.Dictionary> que_fill = new List<Godot.Collections.Dictionary>();
		var canvas_size = (Vector2I)canvasMeta["size"];
		var zoom_level = (int)canvasMeta["zoom_level"];
		var snap_ms_pos_x = (int)(Mathf.Floor(locMsPos.X / ((canvas_size.X * zoom_level) / canvas_size.X)));
		var snap_ms_pos_y = (int)(Mathf.Floor(locMsPos.Y / ((canvas_size.Y * zoom_level) / canvas_size.Y)));
		var snap_ms_pos = new Vector2I(snap_ms_pos_x, snap_ms_pos_y);
		var canvas_layers = (Godot.Collections.Array)canvasMeta["layers"];
		var selected_layer = (int)canvasMeta["selected_layer"];
		var layer = (Godot.Collections.Dictionary)canvas_layers[selected_layer];
		var layer_img = (Image)layer["image"];
		var sample_pixel  = new Color(layer_img.GetPixelv(snap_ms_pos));


		if (actType == 0 && sample_pixel != (Color)canvasMeta["primary_color"] || actType == 1 && sample_pixel != (Color)canvasMeta["secondary_color"])
		{
			var que_pixel = new Godot.Collections.Dictionary{
				{"pos",new Vector2I(snap_ms_pos.X,snap_ms_pos.Y)},
				{"color",(Color)canvasMeta["primary_color"]},
			};
			if (actType == 0){
				que_pixel["color"] = (Color)canvasMeta["primary_color"];
			}
			else{
				que_pixel["color"] = (Color)canvasMeta["secondary_color"];
			}

			que_fill.Add(que_pixel);
			var pPos = (Vector2I)que_fill[0]["pos"];
			var pCol = (Color)que_fill[0]["color"];
			layer_img.SetPixelv(new Vector2I(pPos.X,pPos.Y),pCol);

			while (que_fill.Count > 0)
			{
				pPos = (Vector2I)que_fill[0]["pos"];
				pCol = (Color)que_fill[0]["color"];

				if (pPos.X + 1 < layer_img.GetWidth())
				{
					Godot.Collections.Dictionary que_pixel_right = new Godot.Collections.Dictionary{
						{"pos", new Vector2I(pPos.X + 1, pPos.Y)},
						{"color", pCol},
					};
					if (layer_img.GetPixelv(new Vector2I(pPos.X + 1,pPos.Y)) == sample_pixel)
					{
						layer_img.SetPixelv(new Vector2I(pPos.X + 1,pPos.Y),pCol);
						que_fill.Add(que_pixel_right);
					}

				}
				if (pPos.X - 1 > -1)
				{
					Godot.Collections.Dictionary que_pixel_left = new Godot.Collections.Dictionary{
						{"pos", new Vector2I(pPos.X - 1, pPos.Y)},
						{"color", pCol},
					};
					if (layer_img.GetPixelv(new Vector2I(pPos.X - 1,pPos.Y)) == sample_pixel)
					{
						layer_img.SetPixelv(new Vector2I(pPos.X - 1,pPos.Y),pCol);
						que_fill.Add(que_pixel_left);
					}

				}
				if (pPos.Y + 1 < layer_img.GetHeight())
				{
					Godot.Collections.Dictionary que_pixel_down = new Godot.Collections.Dictionary{
						{"pos", new Vector2I(pPos.X, pPos.Y + 1)},
						{"color", pCol},
					};
					if (layer_img.GetPixelv(new Vector2I(pPos.X,pPos.Y + 1)) == sample_pixel)
					{
						layer_img.SetPixelv(new Vector2I(pPos.X,pPos.Y + 1),pCol);
						que_fill.Add(que_pixel_down);
					}

				}
				if (pPos.Y - 1 > -1)
				{
					Godot.Collections.Dictionary que_pixel_up = new Godot.Collections.Dictionary{
						{"pos", new Vector2I(pPos.X, pPos.Y - 1)},
						{"color", pCol},
					};
					if (layer_img.GetPixelv(new Vector2I(pPos.X,pPos.Y - 1)) == sample_pixel)
					{
						layer_img.SetPixelv(new Vector2I(pPos.X,pPos.Y - 1),pCol);
						que_fill.Add(que_pixel_up);
					}

				}
				
				que_fill.RemoveAt(0);
				
			}
		}
		
	}
}
