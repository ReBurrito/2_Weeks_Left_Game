extends Interactable
#===========================================VARIABLES============================================
@export var snake_game: PackedScene
@export var tv_tuner: PackedScene
#========================================CUSTOM FUNCTIONS========================================
func get_choices() -> Dictionary:
	return {
		"Gamer mode": play_game,
		"The news channel is on.": watch_news,
		"Not yet...": leave_object
	}
"""==========================================================================================="""
func play_game():
	print("I feel more Creative!")
	GameManager.used_object("Creativity", 1)
	spawn_snake_game()

func watch_news():
	print("I feel smarter!")
	GameManager.used_object("Knowledge", 1)
	spawn_tv_tuner_game()

func leave_object():
	print("Maybe later.")
"""==========================================================================================="""
func spawn_snake_game():
	if snake_game:
		var game_instance = snake_game.instantiate()
		get_tree().root.add_child(game_instance)
		get_tree().paused = true
	else:
		print("Error: Snake game scene not assigned in Inspector!")
"""==========================================================================================="""
func spawn_tv_tuner_game():
	if tv_tuner:
		var game_instance = tv_tuner.instantiate()
		get_tree().root.add_child(game_instance)
		get_tree().paused = true
	else:
		print("Error: Snake game scene not assigned in Inspector!")
"""==========================================================================================="""