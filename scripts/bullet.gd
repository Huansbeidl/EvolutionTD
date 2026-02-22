extends Area2D

@export var speed: float = 600.0
@export var damage: int = 5

var target: Node2D = null

func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_instance_valid(target):
		# Turn face to face enemy and move directly to it's position
		look_at(target.global_position)
		global_position = global_position.move_toward(target.global_position, speed*delta)
	else:
		# just keep going until off screen and _on_visible_.. starts to catch these bullets
		position += transform.x * speed * delta 

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemies"):	
		if area.has_method("take_damage"):
			area.take_damage(damage)
		queue_free()
		
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	# Clean up bullets that miss to save memory
	queue_free()
