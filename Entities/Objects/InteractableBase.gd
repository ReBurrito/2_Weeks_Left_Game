extends Area2D
class_name Interactable
#========================================CUSTOM FUNCTIONS========================================
func interact():																																									# Base script for all interactables and the options that will be presented to the user
	var menu = get_tree().current_scene.find_child("ChoiceMenu")
	if menu:
		menu.display_choices(get_choices())
"""==========================================================================================="""
func get_choices() -> Dictionary:
	return {}
"""==========================================================================================="""