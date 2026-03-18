extends Tower
class_name LightningTower

@export var chain_count: int = 2
@export var jump_radius: float = 600.0
@export var damage_multiplier: float = 0.5
@export var bolt_scene: PackedScene

func _ready() -> void:
	super._ready()
	damage = 4

func _process(_delta: float) -> void:
	look_at_target()

func perform_attack() -> void:
	if not is_instance_valid(current_target): # validate before logic
		return
	var bolt_points = [muzzle.global_position] # 
	# ^ initialized as an array from muzzle position because it will grow
	# and we will use it to track all bolt_points
	current_target.take_damage(damage) # damage primary target
	bolt_points.append(current_target.global_position)
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
			chained_damage = max(1, int(chained_damage)) # to prevent 0 dmg 
			next_target.take_damage(chained_damage)
			
			bolt_points.append(next_target.global_position)
			
			affected_targets.append(next_target)
			search_origin = next_target.global_position
		else:
			break
	spawn_bolt(bolt_points) # actually
			
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
			print(t)
			var dist = origin.distance_to(t.global_position)
			if dist < min_dist:
				min_dist = dist
				closest = t
	return closest
	
func spawn_bolt(points: Array):
	var bolt = bolt_scene.instantiate()
	get_tree().root.add_child(bolt) # get_parent().add_child(bolt) might be better
	# if I add a moving camera and stuff
	bolt.create_bolt(points)
