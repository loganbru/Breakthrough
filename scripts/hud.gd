class_name HUD
extends Control

@onready var depth_label : Label = $Margin/VBox/HBox/HBox/DepthLabel
@onready var balls_label : Label = $Margin/VBox/HBox/HBox2/BallsLabel

func update_depth(_value):
	depth_label.text = str(_value)

func update_balls(_value):
	balls_label.text = str(_value)
