extends Node

@onready var game : Game = $Game
@onready var screen_manager : ScreenManager = $ScreenManager

var game_in_progress = false

func _ready():
	DisplayServer.window_set_window_event_callback(_on_window_event)
	screen_manager.connect("new_game", new_game)
	start_game()

func _on_window_event(event):
	match event:
		DisplayServer.WINDOW_EVENT_FOCUS_IN:
			print("Focus in")
		DisplayServer.WINDOW_EVENT_FOCUS_OUT:
			print("Focus out")
			
			if game_in_progress == true && !get_tree().paused:
				pause_game()
		DisplayServer.WINDOW_EVENT_CLOSE_REQUEST:
			get_tree().quit()

func new_game():
	game_in_progress = true
	game.call_deferred("new_game")

func start_game():
	game_in_progress = true

func pause_game():
	get_tree().paused = true
	screen_manager.pause_game()

func _input(event):
	if Input.is_action_just_pressed("pause_game"):
		pause_game()
