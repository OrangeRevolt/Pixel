extends Button


func _on_pressed() -> void:
	owner.get_parent().remove_child(owner)
	owner.queue_free()
