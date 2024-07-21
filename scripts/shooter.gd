class_name Shooter
extends Node2D

signal brick_entered_detector
signal shot_over

@onready var state_chart : StateChart = $StateChart
@onready var ball_spawn_point : Sprite2D = $BallSpawnPoint
@onready var next_hit_indicator : Sprite2D = $NextHitIndicator

@export var ball_scene : PackedScene
@export var ball_count : float = 100
@export var brick_collision_layer: int = 3
@export var max_shot_length : float = 5.0
@export var max_interval : float = 0.1

var ball_container : Node2D = null
var detector : Area2D = null
var indicator_line : IndicatorLine = null
var next_shot_position : Vector2 = Vector2(540, 0)
var return_timeout_timer : float = 0.0
var shots_fired : float = 0
var time_cache : float = 0.0
var is_dragging = false
var first_ball_returned = false
var shooter_width : float = 896

#region SETUP FUNCTIONS
func new_game():
	for _ball in ball_container.get_children():
		_ball.queue_free()
	set_next_shot_position(Vector2(540, 0))
	state_chart.send_event("aim")

func setup_shooter(_shooter_width, _ball_container):
	shooter_width = _shooter_width
	ball_container = _ball_container
	setup_detector()

func setup_indicator_line(_indicator_line):
	if _indicator_line:
		indicator_line = _indicator_line

func setup_detector():
	detector = Area2D.new()
	var _collider : CollisionShape2D = CollisionShape2D.new()
	var _collision_rect_shape : RectangleShape2D = RectangleShape2D.new()
	_collision_rect_shape.size = Vector2(shooter_width, 16)
	_collider.shape = _collision_rect_shape
	_collider.position = Vector2(shooter_width / 2, -8)
	add_child(detector)
	detector.add_child(_collider)
	detector.set_collision_layer_value(1, false)
	detector.set_collision_layer_value(4, true)
	detector.set_collision_mask_value(3, true)
	
	detector.connect("body_entered", _on_detector_body_entered)
#endregion

#region SHOOTING FUNCTIONS
func update_indicator_line(event):
	var start_position = ball_spawn_point.global_position
	var target_position = event.position
	indicator_line.update_line(start_position, target_position)
	# Perform a collision check to find where the line should end

func set_next_shot_position(_return_ball_pos : Vector2):
	next_shot_position = Vector2(_return_ball_pos.x, 0)
	
	if next_shot_position.x > (shooter_width - 16):
		next_shot_position.x = shooter_width - 16
	
	if next_shot_position.x < 16:
		next_shot_position.x = 16
	
	next_hit_indicator.position = next_shot_position

func fire_ball(_direction):
	var new_ball : Ball = ball_scene.instantiate()
	new_ball.set_initial_velocity(_direction)
	new_ball.global_position = ball_spawn_point.global_position
	ball_container.add_child(new_ball)

func _on_detector_body_entered(body):
	if body is Ball:
		if body.velocity.y < 0:
			if first_ball_returned == false:
				first_ball_returned = true
				set_next_shot_position(to_local(body.global_position))
			body.queue_free()
	if body is Brick:
		brick_entered_detector.emit()
#endregion


#region AIMING STATE
func _on_aiming_state_entered():
	ball_spawn_point.position = next_shot_position
	next_hit_indicator.position = next_shot_position
	ball_spawn_point.modulate.a = 1.0

func _on_aiming_state_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_dragging = true
			else:
				is_dragging = false
				indicator_line.hide_line()
				var angle_y_value = ball_spawn_point.global_position.direction_to(event.position).y
				if angle_y_value >= 0.15:
					state_chart.send_event("shoot")
					state_chart.set_expression_property("shot_direction", ball_spawn_point.global_position.direction_to(event.position))
	elif event is InputEventMouseMotion and is_dragging:
		var angle_y_value = ball_spawn_point.global_position.direction_to(event.position).y
		if angle_y_value >= 0.15:
			update_indicator_line(event)
			indicator_line.show_line()
		else:
			indicator_line.hide_line()

func _on_aiming_state_exited():
	ball_spawn_point.modulate.a = 0.5
#endregion

#region SHOOT STATE
func _on_shoot_state_processing(delta):
	return_timeout_timer += delta
	if return_timeout_timer >= 7.5 and first_ball_returned != true and shots_fired >= ball_count:
		first_ball_returned = true
		set_next_shot_position(get_tree().get_nodes_in_group("balls")[0].global_position)

func _on_shoot_state_exited():
	shot_over.emit()
	return_timeout_timer = 0.0
	time_cache = 0.0
	shots_fired = 0.0
#endregion

#region FIRE STATE
func _on_fire_state_entered():
	first_ball_returned = false

func _on_fire_state_processing(delta):
	time_cache += delta
	var shot_interval = max_shot_length / ball_count
	if shot_interval > max_interval:
		shot_interval = max_interval
	if time_cache >= shot_interval:
		time_cache = 0.0
		if shots_fired < ball_count:
			fire_ball(state_chart.get_expression_property("shot_direction"))
			shots_fired += 1
#endregion

#region AWAIT RETURN STATE
func _on_await_return_state_processing(delta):
	if shots_fired >= ball_count:
		var balls_in_scene = get_tree().get_nodes_in_group("balls")
		if balls_in_scene.size() == 0:
			state_chart.send_event("aim")
#endregion
