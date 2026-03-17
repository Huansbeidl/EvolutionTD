extends Node2D

@onready var line = $Line2D

func _ready() -> void:
	pass 

func _process(_delta: float) -> void:
	pass

func create_bolt(points: Array):
	line.points = points
	var tween = create_tween()
	tween.tween_property(line, "modulate:a", 0.0, 0.1) # fade to transparent in .1s
	tween.finished.connect(queue_free)
