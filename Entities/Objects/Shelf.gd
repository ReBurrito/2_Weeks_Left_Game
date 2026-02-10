extends Interactable
#===========================================VARIABLES============================================
@export var sliding_puzzle: PackedScene
@export var steady_hands: PackedScene
#========================================CUSTOM FUNCTIONS========================================
func get_choices() -> Dictionary:
	return {
		"Read a Book.": read_book,
		"Look up DIY Projects": diy_project,
		"Not yet...": leave_object
	}
"""==========================================================================================="""
func read_book():
	print("I feel smarter!")
	GameManager.used_object("Knowledge", 1)
	spawn_sliding_puzzle()

func diy_project():
	print("I feel more Creative!")
	GameManager.used_object("Creativity", 1)
	spawn_steady_heands()

func leave_object():
	print("I'm done reading.")
"""==========================================================================================="""
func spawn_sliding_puzzle():
	if sliding_puzzle:
		var game_instance = sliding_puzzle.instantiate()
		get_tree().root.add_child(game_instance)
		get_tree().paused = true
	else:
		print("Error: Sliding puzzle not assigned in Inspector!")
"""==========================================================================================="""
func spawn_steady_heands():
	if steady_hands:
		var game_instance = steady_hands.instantiate()
		get_tree().root.add_child(game_instance)
		get_tree().paused = true
	else:
		print("Error: Steady Hands not assigned in Inspector!")
"""==========================================================================================="""