extends FileDialog


func _on_file_selected(path: String) -> void:
	%Canvas_Texture.texture.get_image().save_png(path)
	self.hide()
	GlobalSignals.popup_exited.emit()
