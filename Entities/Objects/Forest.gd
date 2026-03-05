extends Interactable
#===========================================VARIABLES============================================
@export var landscape_painting: PackedScene
@export var biking: PackedScene
#========================================CUSTOM FUNCTIONS========================================
func get_choices() -> Dictionary:
	return {
		"What a lovely scene.": painting,
		"Great weather for a bike ride.": ride_bike,
		"Maybe Later...": leave_object
	}
"""==========================================================================================="""
func painting():
	print("I feel more creative!")
	GameManager.used_object("Creativity", 1)
	spawn_painting_game()
"""==========================================================================================="""
func ride_bike():
	print("I feel stronger!")
	GameManager.used_object("Strength", 1)
	spawn_biking_game()
"""==========================================================================================="""
func leave_object():
	print("Maybe later.")
"""==========================================================================================="""
func spawn_painting_game():
	if landscape_painting:
		var game_instance = landscape_painting.instantiate()
		add_child(game_instance)
		get_tree().paused = true
	else:
		print("Error: painting game scene not assigned in Inspector!")
"""==========================================================================================="""
func spawn_biking_game():
	if biking:
		var game_instance = biking.instantiate()
		add_child(game_instance)
		get_tree().paused = true
	else:
		print("Error: biking game scene not assigned in Inspector!")
"""==========================================================================================="""
