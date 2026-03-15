extends Node2D

# This creates the slot in the Inspector you were looking for
@export var enemy_scenes: Array[PackedScene]
@export var tower_scenes: Array[PackedScene]

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

var selected_tower_index: int = 0

func _ready() -> void:
	add_to_group("game_manager")
	current_lives = starting_lives
	current_gold = starting_gold
	switch_tower(0)
	
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
		var snapped_pos = get_snapped_position(get_global_mouse_position())
		if current_gold >= tower_cost and is_placement_valid():
			place_tower(snapped_pos)
		elif current_gold < tower_cost:
			print("Not enough gold!")
		else:
			print("Can't build here!")
			
func is_placement_valid() -> bool:
	# Get Area2D from the Ghost
	for child in ghost.get_children():
		var ghost_area = child.get_node_or_null("PlacementCheck")
		if ghost_area:
			var overlapping_areas = ghost_area.get_overlapping_areas()
			var overlapping_bodies = ghost_area.get_overlapping_bodies()
			return overlapping_areas.size() == 0 and overlapping_bodies.size() == 0
	return false

func place_tower(pos: Vector2) -> void:
	var scene_to_place = tower_scenes[selected_tower_index].instantiate()
	if current_gold >= scene_to_place.cost:
		current_gold -= scene_to_place.cost
		scene_to_place.position = pos
		$TowerContainer.add_child(scene_to_place)
	
func switch_tower(index: int):
	selected_tower_index = index
	# Clear existing preview
	for child in ghost.get_children():
		if child.name != "PlacementCheck":
			child.queue_free()
	
	# Add new preview
	var preview = tower_scenes[index].instantiate()
	# Disable logic as to not shoot or detect enemies
	preview.set_process(false)
	preview.set_physics_process(false)
	# Disable its timer so it doesn't fire bullets
	var timer = preview.get_node_or_null("ShootTimer")
	if timer:
		timer.stop()
	# Disable its collision area so it doesn't detect enemies
	var detection = preview.get_node_or_null("DetectionRange")
	if detection:
		detection.monitoring = false
		detection.monitorable = false
	ghost.add_child(preview)
	
func _process(_delta: float) -> void:
	# Logic for checking if enemies are left
	if enemies_spawned_this_wave >= enemies_per_wave:
		var active_enemies = get_tree().get_nodes_in_group("enemies")
		if active_enemies.size() == 0 and not wave_message_shown:
			print("Wave ", current_wave, " complete! Press 'Spacebar' for next wave.")
			wave_message_shown = true
	
	# Logic for building
	ghost.global_position = get_snapped_position(get_global_mouse_position())
	if current_gold >= tower_cost and is_placement_valid():
		ghost.modulate = Color(0,1,0,0.5)
	else:
		ghost.modulate = Color(1,0,0,0.5)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("tower_1"):
		switch_tower(0)
	elif event.is_action_pressed("tower_2"):
		switch_tower(1)
	elif event.is_action_pressed("ui_accept"):
		if spawn_timer.is_stopped():
			start_next_wave()
			
func start_next_wave():
	wave_message_shown = false
	current_wave += 1
	enemies_spawned_this_wave = 0
	enemies_per_wave += 2
	
	spawn_timer.start()
	
func spawn_enemy() -> void:
	var mover = PathFollow2D.new() # Instantiate Mover
	mover.loop = false # Prevents enemies from teleporting back to start
	mover.set_script(load("res://scripts/mover.gd"))
	
	if enemy_scenes.size() == 0:
		print("Error: No enemy scenes assigned in the Inspector!")
		return
		
	#Instantiate the Enemy Scene
	var random_index = randi() % enemy_scenes.size()
	var new_enemy = enemy_scenes[random_index].instantiate()
	new_enemy.set_wave_difficulty(current_wave)
	# Build the hierarchy FIRST
	path_node.add_child(mover)
	mover.add_child(new_enemy)
	# Set the movement speed AFTER
	mover.speed = new_enemy.speed
	# Apply health bonus LAST

func get_snapped_position(raw_pos: Vector2) -> Vector2:
	var snapped_x = floor(raw_pos.x / 32) * 32 +16
	var snapped_y = floor(raw_pos.y / 32) * 32 +16
	return Vector2(snapped_x, snapped_y)
