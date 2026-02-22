extends Node2D

# This creates the slot in the Inspector you were looking for
@export var enemy_scene: PackedScene 
@export var tower_scene: PackedScene

@export var starting_lives: int = 10
@export var starting_gold: int = 100
@export var tower_cost: int = 50
@export var enemies_per_wave: int = 5

@onready var path_node = $Path2D
@onready var spawn_timer = $SpawnTimer
@onready var ghost = $TowerGhost
@onready var gold_label = $UI/HBoxContainer/GoldLabel
@onready var lives_label = $UI/HBoxContainer/LivesLabel
@onready var wave_label = $UI/HBoxContainer/WaveLabel

var wave_message_shown: bool = false
var enemies_spawned_this_wave: int = 0

var current_wave: int = 1:
	set(value):
		current_wave = value
		if wave_label: wave_label.text = "Wave: " + str(current_wave)
var current_lives: int:
	set(value):
		current_lives = value
		if lives_label: lives_label.text = "Lives" + str(current_lives)
var current_gold: int:
	set(value):
		current_gold = value
		if gold_label: gold_label.text = "Gold" + str(current_gold)

func _ready() -> void:
	add_to_group("game_manager")
	current_lives = starting_lives
	current_gold = starting_gold
	
func lose_life():
	current_lives -= 1
	print("Life lost! Remaining: ", current_lives)
	if current_lives <= 0:
		print("Game Over!")
		# get_tree().reload_current_scene() # Restarts game

func _on_spawn_timer_timeout() -> void: # This function spawns new enemies along the Path
	if enemies_spawned_this_wave < enemies_per_wave:
		spawn_enemy()
		enemies_spawned_this_wave += 1
	else:
		spawn_timer.stop()
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if current_gold >= tower_cost and is_placement_valid():
			place_tower(event.position)
		elif current_gold < tower_cost:
			print("Not enough gold!")
		else:
			print("Can't build here!")
			
func is_placement_valid() -> bool:
	# Get Area2D from the Ghost
	var ghost_area = get_node_or_null("TowerGhost/PlacementCheck")
	# Safety Check: If the node is missing, we assume invalid to prevent building at all
	if ghost_area == null: # alternatively "if not ghost_area: return false" 
		return false
	
	var overlapping_areas = ghost_area.get_overlapping_areas()
	var overlapping_bodies = ghost_area.get_overlapping_bodies()
	return overlapping_areas.size() == 0 and overlapping_bodies.size() == 0

func place_tower(pos: Vector2) -> void:
	current_gold -= tower_cost
	var new_tower = tower_scene.instantiate()
	new_tower.position = pos
	$TowerContainer.add_child(new_tower)
	
func _process(_delta: float) -> void:
	# Logic for checking if enemies are left
	if enemies_spawned_this_wave >= enemies_per_wave:
		var active_enemies = get_tree().get_nodes_in_group("enemies")
		if active_enemies.size() == 0 and not wave_message_shown:
			print("Wave ", current_wave, " complete! Press 'Spacebar' for next wave.")
			wave_message_shown = true
	
	# Logic for building
	ghost.global_position = get_global_mouse_position()
	if current_gold >= tower_cost and is_placement_valid():
		ghost.modulate = Color(0,1,0,0.5)
	else:
		ghost.modulate = Color(1,0,0,0.5)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		if spawn_timer.is_stopped():
			start_next_wave()
			
func start_next_wave():
	wave_message_shown = false
	current_wave += 1
	enemies_spawned_this_wave = 0
	enemies_per_wave += 2
	spawn_timer.start()
	print("Starting Wave: ", current_wave)
	
func spawn_enemy() -> void:
	var mover = PathFollow2D.new() # Instantiate Mover
	mover.loop = false # Prevents enemies from teleporting back to start
	mover.set_script(load("res://scripts/mover.gd"))

	#Instantiate the Enemy Scene
	var new_enemy = enemy_scene.instantiate()
	mover.speed = new_enemy.speed
	
	# Build the hierarchy
	path_node.add_child(mover)
	mover.add_child(new_enemy)
