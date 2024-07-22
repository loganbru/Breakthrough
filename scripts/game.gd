class_name Game
extends Node2D

@onready var hud : HUD = $UILayer/HUD

@export var brick_spawner_position : Vector2
@export var shooter_position : Vector2

@export var brick_spawner_scene : PackedScene
@export var shooter_scene : PackedScene
@export var indicator_line_scene : PackedScene

var effect_container : Node2D = null
var ball_container : Node2D = null
var brick_spawner : BrickSpawner = null
var shooter : Shooter = null
var indicator_line : IndicatorLine = null

func _ready():
	effect_container = Node2D.new()
	effect_container.z_index = 5
	effect_container.add_to_group("global_effect_container")
	add_child(effect_container)
	
	ball_container = Node2D.new()
	add_child(ball_container)
	
	indicator_line = indicator_line_scene.instantiate()
	add_child(indicator_line)
	
	brick_spawner = brick_spawner_scene.instantiate()
	brick_spawner.position = brick_spawner_position
	brick_spawner.connect("depth_changed", _on_brick_spawner_depth_changed)
	brick_spawner.connect("ball_count_changed", _on_brick_spawner_ball_count_changed)
	add_child(brick_spawner)
	
	shooter = shooter_scene.instantiate()
	shooter.position = shooter_position
	shooter.setup_shooter(brick_spawner.grid_width * brick_spawner.grid_size, ball_container, brick_spawner)
	shooter.setup_indicator_line(indicator_line)
	add_child(shooter)
	
	brick_spawner.setup_shooter(shooter)

func new_game():
	brick_spawner.new_game()
	shooter.new_game()

func _on_brick_spawner_depth_changed(_depth):
	hud.update_depth(_depth)

func _on_brick_spawner_ball_count_changed(_ball_count):
	hud.update_balls(_ball_count)
