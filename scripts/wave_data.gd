class_name WaveData
extends Resource

@export var enemy_counts: Dictionary = {} # Key PackedScene, Value: int
@export var spawn_interval: float = 1.0

func get_total_enemies() -> int:
	var total = 0
	for count in enemy_counts.values():
		total += count
	return total
