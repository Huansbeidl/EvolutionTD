extends Tower


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	damage = 50
	fire_rate = 3.0
	bullet_speed = 1200.0
	super._ready()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
