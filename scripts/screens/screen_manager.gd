class_name ScreenManager
extends CanvasLayer

signal new_game

@onready var pause_screen : Control = $PauseScreen
@onready var game_over_screen : Control = $GameOverScreen

var current_screen = null

func _ready():
	register_buttons()
	change_screen(null)

func _process(delta):
	pass

func register_buttons():
	var buttons = get_tree().get_nodes_in_group("buttons")
	
	if buttons.size() > 0:
		for button in buttons:
			if button is ScreenButton:
				button.clicked.connect(_on_button_pressed)

func _on_button_pressed(button):
	print("received")
	match button.name:
		"PauseClose":
			change_screen(null)
			await(get_tree().create_timer(0.75).timeout)
			get_tree().paused = false
		"Restart":
			print("filtered")
			change_screen(null)
			get_tree().paused = false
			await(get_tree().create_timer(0.75).timeout)
			new_game.emit()
			

func change_screen(new_screen):
	# turn off current screen if there is one
	if current_screen != null:
		var disappear_tween = current_screen.disappear()
		await(disappear_tween.finished)
		current_screen.visible = false
	
	# change current screen
	current_screen = new_screen
	
	# make current screen appear if it is not null
	if current_screen != null:
		var appear_tween = current_screen.appear()
		await(appear_tween.finished)
		get_tree().call_group("buttons", "set_disabled", false)

func pause_game():
	change_screen(pause_screen)
