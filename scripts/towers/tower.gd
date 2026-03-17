extends Node2D
class_name Tower

@export var bullet_scene: PackedScene
@export var cost: int = 50
@export var damage: int = 5
@export var fire_rate: float = 1.0 # Seconds between shots
@export var bullet_speed: float = 600.0

# Using @onready to get our specifically named nodes
@onready var muzzle = $Sprite2D/Marker2D 
@onready var shoot_timer = $ShootTimer

var targets: Array = []
var current_target: Node2D = null

func _ready() -> void:
	shoot_timer.wait_time = fire_rate

func _process(_delta: float) -> void:
	look_at_target()

func look_at_target() -> void:
	current_target = get_highest_priority_target()
	if is_instance_valid(current_target):
		$Sprite2D.look_at(current_target.global_position)

func get_highest_priority_target() -> Node2D:
	# Filter out any enemies that were deleted but are still in the array
	var valid_targets = targets.filter(func(t): return is_instance_valid(t))
	if valid_targets.size() > 0:
		return valid_targets[0] # Target the first enemy that entered the range
	return null

func _on_shoot_timer_timeout() -> void:
	if targets.size() > 0:
		shoot()
		
func shoot() -> void:
	if not is_instance_valid(current_target): # validate before logic
		return
	perform_attack()
	
func perform_attack() -> void:	
	var b = bullet_scene.instantiate()
	b.damage = damage
	b.speed = bullet_speed
	b.target = current_target
	get_tree().root.add_child(b)
	b.global_position = muzzle.global_position

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemies"):
		targets.append(area)

func _on_area_2d_area_exited(area: Area2D) -> void:
	if area in targets:
		targets.erase(area)
