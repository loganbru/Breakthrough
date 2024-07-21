class_name ExplosionParticles
extends GPUParticles2D

var time_cache = 0.0
var wait_time = 0.3
var is_setup : bool = false

func _on_finished():
	queue_free()

func setup_explosion(_center_point, _color, _wait_time):
	position = _center_point + Vector2(randf_range(-64, 64), randf_range(-64, 64))
	modulate = _color
	wait_time = _wait_time
	is_setup = true

func _process(delta):
	if is_setup:
		time_cache += delta
		if time_cache >= wait_time:
			emitting = true
