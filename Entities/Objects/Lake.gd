extends Interactable
#===========================================VARIABLES============================================
@export var fish_feeding: PackedScene
@export var fishing: PackedScene
#========================================CUSTOM FUNCTIONS========================================
func get_choices() -> Dictionary:
	return {
		"Let's feed thye fish.": feed_fish,
		"This park allows fishing?": catch_fish,
		"Maybe Later...": leave_object
	}
"""==========================================================================================="""
func feed_fish():
	print("I feel more social!")
	GameManager.used_object("Sociability", 1)
	spawn_fish_feeding_game()
"""==========================================================================================="""
func catch_fish():
	print("I feel stronger!")
	GameManager.used_object("Strength", 1)
	spawn_fishing_game()
"""==========================================================================================="""
func leave_object():
	print("Maybe later.")
"""==========================================================================================="""
func spawn_fish_feeding_game():
	if fish_feeding:
		var game_instance = fish_feeding.instantiate()
		get_tree().root.add_child(game_instance)
		get_tree().paused = true
	else:
		print("Error: Fish feeding game scene not assigned in Inspector!")
"""==========================================================================================="""
func spawn_fishing_game():
	if fishing:
		var game_instance = fishing.instantiate()
		get_tree().root.add_child(game_instance)
		get_tree().paused = true
	else:
		print("Error: Fishing game scene not assigned in Inspector!")
"""==========================================================================================="""