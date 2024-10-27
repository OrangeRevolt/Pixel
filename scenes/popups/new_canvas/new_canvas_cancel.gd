extends Button


func _on_pressed() -> void:
	GlobalSignals.popup_exited.emit()
	owner.get_parent().remove_child(owner)
	owner.queue_free()
