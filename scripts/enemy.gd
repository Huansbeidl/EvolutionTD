extends Area2D

@export var speed: float = 150.0
@export var health: int = 10
var is_dead: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("enemies")

func take_damage(amount: int) -> void:
	if is_dead: return
	
	health -= amount
	print("Enemy hit! Health remaining: ", health)
	if health <= 0:
		die()

func die() -> void:
	if is_dead: return
	is_dead = true
	
	var main = get_tree().get_first_node_in_group("game_manager")
	if main:
		main.current_gold += 25
		print("Earned 25 Gold! Total: ", main.current_gold)
	queue_free() # This is it's own function to add sounds etc. later
