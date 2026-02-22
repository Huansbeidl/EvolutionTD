extends PathFollow2D

var speed: float = 0.0

func _process(delta: float) -> void:
	# This line moves the node along the Path2D curve
	if speed > 0:
		progress += speed * delta
	
	# If the enemy reaches the end of the line, delete it
	if progress_ratio >= 1.0:
		if get_child_count() > 0:
			var enemy = get_child(0)
			if enemy and not enemy.get("is_dead"):
				var main = get_tree().get_first_node_in_group("game_manager")
				if main:
					main.lose_life()
		queue_free()
