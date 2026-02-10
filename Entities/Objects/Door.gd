extends Interactable
#========================================CUSTOM FUNCTIONS========================================
func get_choices() -> Dictionary:
	return {
		"Let's head to the park.": park,
		"Not yet...": leave_object
	}
"""==========================================================================================="""
func park():
	print("Change scene here")
	get_tree().change_scene_to_file("uid://c14m7dy1h6o7v")
"""==========================================================================================="""
func leave_object():
	print("Maybe later.")
"""==========================================================================================="""