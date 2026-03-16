extends Tower
class_name LightningTower

@export var chain_count: int = 2
@export var jump_radius: float = 100.0
@export var damage_multiplier: float = 0.5

func _ready() -> void:
	super._ready()

func _process(_delta: float) -> void:
	pass

func perform_attack() -> void:
	if not is_instance_valid(current_target): # validate before logic
		return
	current_target.take_damage(damage) # damage primary target
	# Chain to secondary targets
	var affected_targets = [current_target] 
	# ^ initialized as an array from current_target
	# because it will grow and we will use it to avoid double hits on same target
	var search_origin = current_target.global_position # used for checking close enmies
	
	for i in range(chain_count):
		var next_target = find_next_target(search_origin, affected_targets)
		if next_target:
			# Apply diminishing damage
			var chained_damage = int(damage * pow(damage_multiplier, i+1))
			next_target.take_damage(chained_damage)
			
			affected_targets.append(next_target)
			search_origin = next_target.global_position
		else:
			break
			
func find_next_target(origin: Vector2, exclude: Array) -> Node2D:
	"""
	Used for finding targets to chain to
		origin - starting position
		exclude - targets to not hit (used for already hit targets)
	"""
	var closest = null
	var min_dist = jump_radius
	
	for t in targets:
		if is_instance_valid(t) and not t in exclude:
			var dist = origin.distance_to(t.global_position)
			if dist < min_dist:
				min_dist = dist
				closest = t
	return closest
	
