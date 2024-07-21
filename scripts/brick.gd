class_name Brick
extends CharacterBody2D

#region STARTING VARS
@onready var state_chart : StateChart = $StateChart

@export var health_font : Font
@export var health_font_size : float = 48
@export var health_font_color : Color = Color.WHITE
@export var health_font_outline_size : float = 0
@export var health_font_outline_color : Color = Color.WHITE
@export var base_brick_colors : Array[Color] = [Color(0.016, 0.4, 0.784), Color(0.012, 0.325, 0.643), Color(0.008, 0.243, 0.49)]
@export var explosion_scene : PackedScene

var health_label : Label = null
var health = 100
var max_health : int
var sprite_dir = "res://assets/images/sprites/"
var brick_variant : Dictionary
var brick_variants : Array[Dictionary] = [
		{
		"sprite_file": "3x1_brick.png",
		"health_label_offset": Vector2(0, 0),
		"footprint": [
		[
			true
		],
		[
			true
		],
		[
			true
		]
		],
		"sprite_position": Vector2(64,
		192),
		"sprite_rotation": 1.57079994678497,
		"colliders": [
		{
			"shape_radius": 64,
			"shape_height": 384,
			"position": Vector2(64,
			192),
			"rotation": 3.1415901184082
		}
		]
	},
	{
		"sprite_file": "L_shape.png",
		"health_label_offset": Vector2(0, 64),
		"footprint": [
		[
			false,
			false,
			true
		],
		[
			true,
			true,
			true
		]
		],
		"sprite_position": Vector2(192,
		128),
		"sprite_rotation": 3.1415901184082,
		"colliders": [
		{
			"shape_radius": 64,
			"shape_height": 384,
			"position": Vector2(192,
			192),
			"rotation": 4.71238994598389
		},
		{
			"shape_radius": 64,
			"shape_height": 256,
			"position": Vector2(320,
			128),
			"rotation": 3.1415901184082
		}
		]
	},
	{
		"sprite_file": "t_shape.png",
		"health_label_offset": Vector2(0, 0),
		"footprint": [
		[
			false,
			true
		],
		[
			true,
			true
		],
		[
			false,
			true
		]
		],
		"sprite_position": Vector2(128,
		192),
		"sprite_rotation": 4.71238994598389,
		"colliders": [
		{
			"shape_radius": 64,
			"shape_height": 384,
			"position": Vector2(192,
			192),
			"rotation": 3.1415901184082
		},
		{
			"shape_radius": 64,
			"shape_height": 256,
			"position": Vector2(128,
			192),
			"rotation": 1.57079994678497
		}
		]
	},
	{
		"sprite_file": "L_shape_small.png",
		"health_label_offset": Vector2(0, -64),
		"footprint": [
		[
			true,
			true
		],
		[
			true,
			false
		]
		],
		"sprite_position": Vector2(128,
		128),
		"sprite_rotation": 3.1415901184082,
		"colliders": [
		{
			"shape_radius": 64,
			"shape_height": 256,
			"position": Vector2(64,
			128),
			"rotation": 0
		},
		{
			"shape_radius": 64,
			"shape_height": 256,
			"position": Vector2(128,
			64),
			"rotation": 1.57079994678497
		}
		]
	},
	{
		"sprite_file": "L_shape.png",
		"health_label_offset": Vector2(0, -64),
		"footprint": [
		[
			true,
			true,
			true
		],
		[
			true,
			false,
			false
		]
		],
		"sprite_position": Vector2(192,
		128),
		"sprite_rotation": 0,
		"colliders": [
		{
			"shape_radius": 64,
			"shape_height": 384,
			"position": Vector2(192,
			64),
			"rotation": 1.57079994678497
		},
		{
			"shape_radius": 64,
			"shape_height": 256,
			"position": Vector2(64,
			128),
			"rotation": 0
		}
		]
	},
	{
		"sprite_file": "L_shape_small.png",
		"health_label_offset": Vector2(0, 64),
		"footprint": [
		[
			true,
			false
		],
		[
			true,
			true
		]
		],
		"sprite_position": Vector2(128,
		128),
		"sprite_rotation": 7.85398006439209,
		"colliders": [
		{
			"shape_radius": 64,
			"shape_height": 256,
			"position": Vector2(128,
			192),
			"rotation": 4.71238994598389
		},
		{
			"shape_radius": 64,
			"shape_height": 256,
			"position": Vector2(64,
			128),
			"rotation": 6.28318977355957
		}
		]
	},
	{
		"sprite_file": "L_shape.png",
		"health_label_offset": Vector2(0, -128),
		"footprint": [
		[
			true,
			true
		],
		[
			false,
			true
		],
		[
			false,
			true
		]
		],
		"sprite_position": Vector2(128,
		192),
		"sprite_rotation": 1.57079994678497,
		"colliders": [
		{
			"shape_radius": 64,
			"shape_height": 384,
			"position": Vector2(192,
			192),
			"rotation": 3.1415901184082
		},
		{
			"shape_radius": 64,
			"shape_height": 256,
			"position": Vector2(128,
			64),
			"rotation": 1.57079994678497
		}
		]
	},
	{
		"sprite_file": "2x1_brick.png",
		"health_label_offset": Vector2(0, 0),
		"footprint": [
		[
			true,
			true
		]
		],
		"sprite_position": Vector2(128,
		64),
		"sprite_rotation": 0,
		"colliders": [
		{
			"shape_radius": 64,
			"shape_height": 256,
			"position": Vector2(128,
			64),
			"rotation": 1.57079994678497
		}
		]
	},
	{
		"sprite_file": "2x1_brick.png",
		"health_label_offset": Vector2(0, 0),
		"footprint": [
		[
			true
		],
		[
			true
		]
		],
		"sprite_position": Vector2(64,
		128),
		"sprite_rotation": 1.57079994678497,
		"colliders": [
		{
			"shape_radius": 64,
			"shape_height": 256,
			"position": Vector2(64,
			128),
			"rotation": 3.1415901184082
		}
		]
	},
	{
		"sprite_file": "t_shape.png",
		"health_label_offset": Vector2(0, 0),
		"footprint": [
		[
			true,
			false
		],
		[
			true,
			true
		],
		[
			true,
			false
		]
		],
		"sprite_position": Vector2(128,
		192),
		"sprite_rotation": 7.85398006439209,
		"colliders": [
		{
			"shape_radius": 64,
			"shape_height": 384,
			"position": Vector2(64,
			192),
			"rotation": 6.28318977355957
		},
		{
			"shape_radius": 64,
			"shape_height": 256,
			"position": Vector2(128,
			192),
			"rotation": 4.71238994598389
		}
		]
	},
	{
		"sprite_file": "t_shape.png",
		"health_label_offset": Vector2(0, -64),
		"footprint": [
		[
			true,
			true,
			true
		],
		[
			false,
			true,
			false
		]
		],
		"sprite_position": Vector2(192,
		128),
		"sprite_rotation": 3.1415901184082,
		"colliders": [
		{
			"shape_radius": 64,
			"shape_height": 384,
			"position": Vector2(192,
			64),
			"rotation": 1.57079994678497
		},
		{
			"shape_radius": 64,
			"shape_height": 256,
			"position": Vector2(192,
			128),
			"rotation": 0
		}
		]
	},
	{
		"sprite_file": "t_shape.png",
		"health_label_offset": Vector2(0, 64),
		"footprint": [
		[
			false,
			true,
			false
		],
		[
			true,
			true,
			true
		]
		],
		"sprite_position": Vector2(192,
		128),
		"sprite_rotation": 6.28318977355957,
		"colliders": [
		{
			"shape_radius": 64,
			"shape_height": 384,
			"position": Vector2(192,
			192),
			"rotation": 4.71238994598389
		},
		{
			"shape_radius": 64,
			"shape_height": 256,
			"position": Vector2(192,
			128),
			"rotation": 3.1415901184082
		}
		]
	},
	{
		"sprite_file": "L_shape.png",
		"health_label_offset": Vector2(0, 128),
		"footprint": [
		[
			true,
			false
		],
		[
			true,
			false
		],
		[
			true,
			true
		]
		],
		"sprite_position": Vector2(128,
		192),
		"sprite_rotation": -1.57079994678497,
		"colliders": [
		{
			"shape_radius": 64,
			"shape_height": 384,
			"position": Vector2(64,
			192),
			"rotation": 0
		},
		{
			"shape_radius": 64,
			"shape_height": 256,
			"position": Vector2(128,
			320),
			"rotation": -1.57079994678497
		}
		]
	},
	{
		"sprite_file": "L_shape_small.png",
		"health_label_offset": Vector2(0, 64),
		"footprint": [
		[
			false,
			true
		],
		[
			true,
			true
		]
		],
		"sprite_position": Vector2(128,
		128),
		"sprite_rotation": 6.28318977355957,
		"colliders": [
		{
			"shape_radius": 64,
			"shape_height": 256,
			"position": Vector2(192,
			128),
			"rotation": 3.1415901184082
		},
		{
			"shape_radius": 64,
			"shape_height": 256,
			"position": Vector2(128,
			192),
			"rotation": 4.71238994598389
		}
		]
	},
	{
		"sprite_file": "3x1_brick.png",
		"health_label_offset": Vector2(0, 0),
		"footprint": [
		[
			true,
			true,
			true
		]
		],
		"sprite_position": Vector2(192,
		64),
		"sprite_rotation": 0,
		"colliders": [
		{
			"shape_radius": 64,
			"shape_height": 384,
			"position": Vector2(192,
			64),
			"rotation": 1.57079994678497
		}
		]
	},
	{
		"sprite_file": "L_shape_small.png",
		"health_label_offset": Vector2(0, -64),
		"footprint": [
		[
			true,
			true
		],
		[
			false,
			true
		]
		],
		"sprite_position": Vector2(128,
		128),
		"sprite_rotation": 4.71238994598389,
		"colliders": [
		{
			"shape_radius": 64,
			"shape_height": 256,
			"position": Vector2(128,
			64),
			"rotation": 1.57079994678497
		},
		{
			"shape_radius": 64,
			"shape_height": 256,
			"position": Vector2(192,
			128),
			"rotation": 3.1415901184082
		}
		]
	},
	{
		"sprite_file": "2x2_brick.png",
		"health_label_offset": Vector2(0, 0),
		"footprint": [
		[
			true,
			true
		],
		[
			true,
			true
		]
		],
		"sprite_position": Vector2(128,
		128),
		"sprite_rotation": 0,
		"colliders": [
			{
				"shape_radius": 64,
				"shape_height": 256,
				"position": Vector2(192,
				128),
				"rotation": 0
			},
			{
				"shape_radius": 64,
				"shape_height": 256,
				"position": Vector2(64,
				128),
				"rotation": 0
			},
			{
				"shape_radius": 64,
				"shape_height": 256,
				"position": Vector2(128,
				192),
				"rotation": 1.57079994678497
			},
			{
				"shape_radius": 64,
				"shape_height": 256,
				"position": Vector2(128,
				64),
				"rotation": 1.57079994678497
			}
		]
	}
]
var sprite : Sprite2D
var colliders : Array[CollisionShape2D]
var brick_footprint : Array
#endregion

#region SETUP
func _ready():
	set_collision_layer_value(1, false)
	set_collision_layer_value(3, true)
	safe_margin = 0.001
	
	sprite.modulate = base_brick_colors[randi_range(0, base_brick_colors.size() - 1)]

func setup_nodes(variant_index):
	brick_variant = brick_variants[variant_index]
	brick_footprint = brick_variant.footprint
	sprite = Sprite2D.new()
	sprite.texture = load(sprite_dir + brick_variant.sprite_file)
	sprite.position = brick_variant.sprite_position
	sprite.rotation = brick_variant.sprite_rotation
	add_child(sprite)
	#{
			#"shape_radius": 64,
			#"shape_height": 384,
			#"position": Vector2(64,
			#192),
			#"rotation": 3.1415901184082
		#}
	for _collision_shape_variant in brick_variant.colliders:
		var _collision_shape = CollisionShape2D.new()
		var _collision_shape_capsule = CapsuleShape2D.new()
		_collision_shape_capsule.radius = _collision_shape_variant.shape_radius
		_collision_shape_capsule.height = _collision_shape_variant.shape_height
		_collision_shape.shape = _collision_shape_capsule
		_collision_shape.position = _collision_shape_variant.position
		_collision_shape.rotation = _collision_shape_variant.rotation
		add_child(_collision_shape)
		colliders.append(_collision_shape)

func setup_health(_health_value):
	health = _health_value
	max_health = _health_value
	
	health_label = Label.new()
	health_label.text = str(health)
	
	var health_label_settings : LabelSettings = LabelSettings.new()
	health_label_settings.font = health_font
	health_label_settings.font_color = health_font_color
	health_label_settings.font_size = health_font_size
	
	if health_font_outline_size > 0.0:
		health_label_settings.outline_size = health_font_outline_size
		health_label_settings.outline_color = health_font_outline_color
	
	health_label.label_settings = health_label_settings
	health_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	var sprite_rect = Tools.get_rotated_bounding_box_size(sprite)
	
	health_label.size = Vector2(128, 72)
	
	health_label.position.x = (sprite_rect.x / 2) - (health_label.size.x / 2)
	health_label.position.y = (sprite_rect.y / 2) - (health_label.size.y / 2)
	
	var _offset : Vector2 = brick_variant.health_label_offset
	if _offset != Vector2(0, 0):
		health_label.position = health_label.position + _offset
	
	add_child(health_label)
	
#endregion

#region BASE FUNCTIONS
func hit():
	health -= 1
#endregion

#region INSTANCED STATE
func _on_instanced_state_processing(delta):
	if sprite.modulate.a > 0.2:
		sprite.modulate.a = float(health) / float(max_health)
	
	if health <= 0:
		state_chart.send_event("destroyed")
	else:
		health_label.text = str(health)
#endregion

#region DESTROYED STATE
func _on_destroyed_state_entered():
	for _collider : CollisionShape2D in colliders:
		_collider.disabled = true
	var disappear_tween = get_tree().create_tween()
	disappear_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	disappear_tween.tween_property(sprite, "modulate:a", 0.0, 0.2).set_ease(Tween.EASE_IN_OUT)
	var label_disappear_tween = get_tree().create_tween()
	label_disappear_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	label_disappear_tween.tween_property(health_label, "modulate:a", 0.0, 0.2).set_ease(Tween.EASE_IN_OUT)
	
	var explosion_count = randi_range(1, 4)
	var explosion_center_point = to_global(Vector2(sprite.texture.get_width() / 2, sprite.texture.get_height() / 2))
	var explosion_particle_color : Color = sprite.modulate
	explosion_particle_color.a = 1.0
	
	for i in explosion_count:
		var _explosion : ExplosionParticles = explosion_scene.instantiate()
		var wait_time = 0.0 if i == 0 else randf_range(0.1, 1)
		_explosion.setup_explosion(explosion_center_point, explosion_particle_color, wait_time)
		get_tree().get_first_node_in_group("global_effect_container").add_child(_explosion)
#endregion

func _on_delete_state_entered():
	queue_free()
