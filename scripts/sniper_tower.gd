extends Tower
class_name SniperTower

func _ready() -> void:
	super._ready()
	damage = 50
	fire_rate = 3.0
	bullet_speed = 1200.0

func _process(_delta: float) -> void:
	pass
