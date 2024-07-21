class_name BrickSpawner
extends Node2D

@onready var background : Panel = $Background
@onready var grid_container : Node2D = $GridContainer

@export var grid_size = 128
@export var grid_width = 7
@export var grid_height = 13
@export var lead_rows = 4
@export var brick_scene : PackedScene

var shooter : Shooter = null
var brick_container_start_position : Vector2 = Vector2(0, 0)
var grid_objs : Array = []
var move_up_counter : int = 0
var depth : int = 0
var grids_generated : int = 0
var left_barrier : StaticBody2D = null
var right_barrier : StaticBody2D = null
var bottom_barrier : StaticBody2D = null

#region SETUP FUNCTIONS
func _ready():
	brick_container_start_position = Vector2(0, grid_height * 128)
	background.size = Vector2(grid_width * 128, grid_height * 128)
	build_barriers()
	#new_game()

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
	move_grid_up()
#endregion

func _input(event):
	if Input.is_action_just_pressed("debug_move_grid_up"):
		move_grid_up()

#region DIFFICULTY CALCULATIONS
func calculate_brick_health() -> int:
	return 10

func calculate_empty_space():
	if randf() < 0.9:
		return true
	else:
		return false
#endregion

#region CONTROL FUNCTIONS
func new_game():
	for _brick_container in grid_container.get_children():
		_brick_container.queue_free()
	
	move_up_counter = 0
	grids_generated = 0
	depth = 0
	grid_objs.clear()
	
	generate_and_populate_new_grid()
#endregion

#region BRICK/GRID FUNCTIONS
func get_highest_brick():
	var highest_y = 100000000
	var highest_brick : Brick = null
	for _grid in grid_container.get_children():
		var _highest_y = 100000000
		var _highest_brick : Brick = null
		for _brick : Brick in _grid.get_children():
			if _brick.global_position.y < _highest_y:
				_highest_y = _brick.global_position.y
				_highest_brick = _brick
		if _highest_y < highest_y:
			highest_y = _highest_y
			highest_brick = _highest_brick
	print(highest_brick)
	return highest_brick

func generate_and_populate_new_grid():
	var new_grid_obj = initialize_grid()
	grid_objs.append(new_grid_obj)
	populate_bricks(grid_objs.size() - 1)
	grids_generated += 1
	call_deferred("move_grid_up")

func initialize_grid():
	var _grid = []
	for y in range(grid_height):
		var row = []
		for x in range(grid_width):
			row.append(false)
		_grid.append(row)
	var _brick_container = Node2D.new()
	_brick_container.position = brick_container_start_position
	grid_container.add_child(_brick_container)
	
	return {
		"grid" : _grid,
		"container" : _brick_container
	}

func move_grid_up():
	var highest_brick = get_highest_brick()
	if highest_brick == null:
		generate_and_populate_new_grid()
		call_deferred("move_grid_up")
		return
	var move_amount = to_local(highest_brick.global_position).y - (lead_rows * 128)
	
	if move_amount < 128:
		move_amount = 128
	
	for grib_obj in grid_objs:
		var _new_pos : Vector2 = grib_obj.container.position + Vector2(0, -move_amount)
		var move_tween = get_tree().create_tween()
		move_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		move_tween.tween_property(grib_obj.container, "position", _new_pos, 0.5).set_ease(Tween.EASE_IN_OUT)
	
	move_up_counter += move_amount / 128
	
	if move_up_counter >= grid_height + 1:
		move_up_counter = 0
		generate_and_populate_new_grid()
	depth += move_amount / 128

func populate_bricks(grid_obj_index):
	for y in range(grid_height):
		for x in range(grid_width):
			if calculate_empty_space():
				continue  # Leave this cell empty

			var brick_instance = brick_scene.instantiate()
			var brick_variant_index = randi_range(0, brick_instance.brick_variants.size() - 1)
			if can_place_brick(grid_obj_index, brick_instance, brick_variant_index, x, y):
				brick_instance.position = Vector2(x * grid_size, y * grid_size)
				brick_instance.setup_nodes(brick_variant_index)
				grid_objs[grid_obj_index].container.add_child(brick_instance)
				brick_instance.setup_health(calculate_brick_health())
				mark_grid_with_brick(grid_obj_index, brick_instance, brick_variant_index, x, y)
			else:
				brick_instance.queue_free()

func can_place_brick(grid_obj_index, brick_instance, brick_variant_index, x, y):
	var footprint = brick_instance.brick_variants[brick_variant_index].footprint
	var footprint_height = footprint.size()
	var footprint_width = footprint[0].size()

	for i in range(footprint_height):
		for j in range(footprint_width):
			if footprint[i][j]:
				var grid_x = x + j
				var grid_y = y + i
				if grid_x >= grid_width or grid_y >= grid_height or grid_x < 0 or grid_y < 0:
					return false
				if grid_objs[grid_obj_index].grid[grid_y][grid_x]:
					return false
	return true

func mark_grid_with_brick(grid_obj_index, brick_instance, brick_variant_index, x, y):
	var footprint = brick_instance.brick_variants[brick_variant_index].footprint
	var footprint_height = footprint.size()
	var footprint_width = footprint[0].size()

	for i in range(footprint_height):
		for j in range(footprint_width):
			if footprint[i][j]:
				var grid_x = x + j
				var grid_y = y + i
				grid_objs[grid_obj_index].grid[grid_y][grid_x] = true
#endregion
