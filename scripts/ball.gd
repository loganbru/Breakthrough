class_name Ball
extends CharacterBody2D

@onready var state_chart : StateChart = $StateChart
@onready var collision_shape : CollisionShape2D = $CollisionShape
@onready var sprite : Sprite2D = $Sprite

@export var speed : float = 1700
@export var hit_timeout : float = 5.0

var initial_velocity : Vector2
var time_cache : float = 0.0

var bounce_count = 0

#region SETUP
func _ready():
	velocity = initial_velocity

func set_initial_velocity(direction : Vector2):
	initial_velocity = direction.normalized() * speed
#endregion

#region SHOT STATE
func _on_shot_state_entered():
	pass

func _on_shot_state_physics_processing(delta):
	time_cache += delta
	
	var hit_timeout_percent = time_cache / hit_timeout
	if hit_timeout_percent > 0.7:
		hit_timeout_percent = 0.7
	sprite.modulate.a = 1.0 - hit_timeout_percent
	
	if time_cache >= hit_timeout:
		state_chart.send_event("return")
	
	var collision_info = move_and_collide(velocity * delta)
	if collision_info:
		bounce_count += 1
		var speed_multiplier = 1 + (bounce_count * 0.001)
		if speed_multiplier > 1.05:
			speed_multiplier = 1.05
		velocity = velocity.bounce(collision_info.get_normal()) * speed_multiplier
		var collider = collision_info.get_collider()
		if collider is Brick:
			time_cache = 0.0
			collider.hit()
#endregion

#region RETURN STATE
func _on_return_state_entered():
	collision_shape.disabled = true
	velocity.x = 0
	velocity.y = -3000

func _on_return_state_physics_processing(delta):
	move_and_slide()
#endregion

#region DELETE STATE
func _on_delete_state_entered():
	queue_free()
#endregion
