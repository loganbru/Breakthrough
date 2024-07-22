class_name BrickSpawner
extends Node2D

signal depth_changed(_depth)
signal ball_count_changed(_ball_count)

@onready var state_chart : StateChart = $StateChart
@onready var background : ColorRect = $Background
@onready var grid_container : Node2D = $GridContainer

@export var grid_size = 128
@export var grid_width = 7
@export var grid_height = 13
@export var lead_rows = 4
@export var brick_scene : PackedScene

var ball_buff : int = 0
var shooter : Shooter = null
var left_barrier : StaticBody2D = null
var right_barrier : StaticBody2D = null
var bottom_barrier : StaticBody2D = null
var grid_move_amount : float = 0.0
var grid_move_pos : Vector2 = Vector2.ZERO

var game_object : GameObject = null
var ready_for_shot : bool = false

func _input(event):
	if Input.is_action_just_pressed("debug_move_grid_up"):
		state_chart.send_event("move_up")

#region SETUP FUNCTIONS
func _ready():
	background.size = Vector2(grid_width * grid_size, grid_height * grid_size)
	build_barriers()

func new_game():
	state_chart.send_event("new_game")

func setup_shooter(_shooter):
	if _shooter:
		shooter = _shooter
		shooter.connect("shot_over", _on_shooter_shot_over)

func build_barriers():
	var viewport_size = get_viewport().get_visible_rect().size
	
	left_barrier = StaticBody2D.new()
	var left_barrier_collider : CollisionShape2D = CollisionShape2D.new()
	var left_barrier_collision_shape : RectangleShape2D = RectangleShape2D.new()
	left_barrier_collision_shape.size = Vector2(16, (grid_height * 128) * 2)
	var local_coords = to_local(Vector2(-8, viewport_size.y / 2))
	left_barrier.position = Vector2(-8, local_coords.y)
	left_barrier_collider.shape = left_barrier_collision_shape
	left_barrier.set_collision_layer_value(1, false)
	left_barrier.set_collision_layer_value(2, true)
	add_child(left_barrier)
	left_barrier.add_child(left_barrier_collider)
	
	right_barrier = StaticBody2D.new()
	var right_barrier_collider : CollisionShape2D = CollisionShape2D.new()
	var right_barrier_collision_shape : RectangleShape2D = RectangleShape2D.new()
	right_barrier_collision_shape.size = Vector2(16, (grid_height * 128) * 2)
	var _local_coords = to_local(Vector2((grid_width * 128) + 8, viewport_size.y / 2))
	right_barrier.position = Vector2((grid_width * 128) + 8, local_coords.y)
	right_barrier_collider.shape = right_barrier_collision_shape
	right_barrier.set_collision_layer_value(1, false)
	right_barrier.set_collision_layer_value(2, true)
	add_child(right_barrier)
	right_barrier.add_child(right_barrier_collider)
	
	bottom_barrier = StaticBody2D.new()
	var bottom_barrier_collider : CollisionShape2D = CollisionShape2D.new()
	var bottom_barrier_collision_shape : RectangleShape2D = RectangleShape2D.new()
	bottom_barrier_collision_shape.size = Vector2(grid_width * 128, 16)
	bottom_barrier.position = Vector2((grid_width * 128) / 2, (grid_height * 128) + 8)
	bottom_barrier_collider.shape = bottom_barrier_collision_shape
	bottom_barrier.set_collision_layer_value(1, false)
	bottom_barrier.set_collision_layer_value(2, true)
	add_child(bottom_barrier)
	bottom_barrier.add_child(bottom_barrier_collider)
#endregion

#region SIGNAL CALLBACKS
func _on_shooter_shot_over():
	state_chart.send_event("move_up")
#endregion

#region DIFFICULTY CALCULATION:
func calculate_ball_count():
	var new_count = (shooter.ball_count + 1) + ball_buff
	if new_count > 99:
		new_count = 99
	shooter.ball_count = new_count
	ball_count_changed.emit(shooter.ball_count)

func brick_health():
	var health_vals : Array
	if game_object.depth >= 0 and game_object.depth <= 63:
		health_vals = [16, 32]
	if game_object.depth >= 64 and game_object.depth <= 127:
		health_vals = [64, 80, 96]
	if game_object.depth >= 128 and game_object.depth <= 191:
		health_vals = [128, 144, 160, 176]
	if game_object.depth >= 192 and game_object.depth <= 255:
		health_vals = [192, 208, 224, 240]
	if game_object.depth >= 256 and game_object.depth <= 511:
		health_vals = [256, 288, 320, 352, 384, 416, 448, 480]
	if game_object.depth >= 512:
		health_vals = [512, 630, 758, 886, 1024]
	
	var rand_index = randi_range(0, health_vals.size() - 1)
	return health_vals[rand_index]

func empty_space_prob():
	var base = 0.8
	var chance_one = 0.1 if randf() > 0.9 else 0.0
	var chance_two = -0.1 if randf() > 0.9 else 0.0
	var chance_three = -0.3 if randf() > 0.95 else 0.0
	var chance_four = -0.2 if randf() > 0.65 else 0.0
	return base + chance_one + chance_two + chance_three + chance_four
#endregion

#region GRID FUNCTIONS
func find_highest_brick():
	var highest_y = 100000000
	var highest_brick : Brick = null
	for _brick : Brick in grid_container.get_children():
			if _brick.global_position.y < highest_y:
				if _brick.marked_for_deletion == false and _brick.is_queued_for_deletion() == false:
					highest_y = _brick.global_position.y
					highest_brick = _brick
	return highest_brick

func check_placement(y_index_min, y_index_max, brick_instance, brick_variant_index, x, y):
	var footprint = brick_instance.brick_variants[brick_variant_index].footprint
	var footprint_height = footprint.size()
	var footprint_width = footprint[0].size()

	for i in range(footprint_height):
		for j in range(footprint_width):
			if footprint[i][j]:
				var grid_x = x + j
				var grid_y = y + i
				if grid_x >= grid_width or grid_y >= y_index_max or grid_x < 0 or grid_y < y_index_min:
					return false
				if game_object.grid[grid_y][grid_x]:
					return false
	return true

func mark_placement(y_index_min, y_index_max, brick_instance, brick_variant_index, x, y):
	var footprint = brick_instance.brick_variants[brick_variant_index].footprint
	var footprint_height = footprint.size()
	var footprint_width = footprint[0].size()

	for i in range(footprint_height):
		for j in range(footprint_width):
			if footprint[i][j]:
				var grid_x = x + j
				var grid_y = y + i
				game_object.grid[grid_y][grid_x] = true
#endregion

#region IDLE STATE
func _on_idle_state_entered():
	ready_for_shot = true

func _on_idle_state_processing(delta):
	pass

func _on_idle_state_exited():
	ready_for_shot = false
#endregion

#region NEW GAME
func _on_new_game_state_entered():
	var _game_object : GameObject = GameObject.new()
	game_object = _game_object
	game_object.grid_start_position = Vector2(0, grid_height * grid_size)
	shooter.ball_count = shooter.starting_ball_count
	ball_buff = 0
	
	for _child in grid_container.get_children():
		_child.queue_free()
		
	grid_container.position = game_object.grid_start_position
	
	state_chart.send_event("create_grid")

#endregion

#region CREATE GRID
func _on_creating_grid_state_entered():
	var _grid = []
	for y in range(grid_height):
		var row = []
		for x in range(grid_width):
			row.append(false)
		game_object.grid.append(row)
	
	game_object.grid = Tools.merge_arrays(game_object.grid, _grid)
	game_object.grid_count += 1
	
	var grid_index = game_object.grid_count - 1
	
	var y_index_min = grid_index * grid_height
	var y_index_max = ((grid_index + 1) * grid_height) - 1
	for y in range(y_index_min, y_index_max):
		for x in range(grid_width):
			if randf() < empty_space_prob():
				continue  # Leave this cell empty
			var brick_instance = brick_scene.instantiate()
			var brick_variant_index = randi_range(0, brick_instance.brick_variants.size() - 1)
			if check_placement(y_index_min, y_index_max, brick_instance, brick_variant_index, x, y):
				brick_instance.position = Vector2(x * grid_size, y * grid_size)
				brick_instance.setup_nodes(brick_variant_index)
				grid_container.add_child(brick_instance)
				brick_instance.setup_health(brick_health())
				mark_placement(y_index_min, y_index_max, brick_instance, brick_variant_index, x, y)
			else:
				brick_instance.queue_free()
	
	calculate_ball_count()
	state_chart.send_event("move_up")
#endregion

#region MOVING UP
func _on_moving_up_state_entered():
	var highest_brick = find_highest_brick()
	
	if highest_brick == null:
		game_object.move_up_counter = 0
		state_chart.send_event("create_grid")
	else:
		var move_amount = to_local(highest_brick.global_position).y - (lead_rows * grid_size)
		if move_amount < grid_size:
			move_amount = grid_size
		
		var _new_pos : Vector2 = grid_container.position + Vector2(0, -move_amount)
		var move_tween = get_tree().create_tween()
		move_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		move_tween.tween_property(grid_container, "position", _new_pos, 0.5).set_ease(Tween.EASE_IN_OUT)
		#grid_container.position = _new_pos
		
		game_object.move_up_counter += move_amount / grid_size
		if game_object.move_up_counter >= grid_height + 1:
			game_object.move_up_counter = 0
			state_chart.send_event("create_grid")
		
		game_object.depth += move_amount / grid_size
		depth_changed.emit(game_object.depth)
		state_chart.send_event("idle")
#endregion

