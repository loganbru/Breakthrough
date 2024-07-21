class_name IndicatorLine
extends Line2D

func _ready():
	top_level = true
	visible = false

func update_line(_start_pos : Vector2, _end_pos : Vector2):
	var space_state = get_world_2d().direct_space_state
	var physics_query = PhysicsRayQueryParameters2D.create(_start_pos, _end_pos)
	var result = space_state.intersect_ray(physics_query)
	if result:
		_end_pos = result.position

	# Update the points of the Line2D
	points = [_start_pos, _end_pos]

func show_line():
	visible = true

func hide_line():
	visible = false
