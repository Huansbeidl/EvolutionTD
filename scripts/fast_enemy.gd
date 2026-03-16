extends Enemy

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	speed = 300.0
	health = 5
	gold_reward = 15
	super._ready() # Add to enemies group, set healthbar
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
