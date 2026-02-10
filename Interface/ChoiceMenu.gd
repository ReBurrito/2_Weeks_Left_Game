extends VBoxContainer
#===========================================VARIABLES============================================
@onready var template = $ButtonTemplate
"""==========================================================================================="""
var can_interact = false
#========================================CUSTOM FUNCTIONS========================================
func display_choices(options: Dictionary):																												# Custom function to display the possible options for how the player can interact with the object
	can_interact = false
	for child in get_children():																																		# Helps clear out the old buttons so that new ones can replace them
		if child != template:
			child.queue_free()
	for button_text in options.keys():																															# Create buttons based on how many options are provided by the dictionary
		var new_btn = template.duplicate()
		add_child(new_btn)
		new_btn.show()
		new_btn.text = button_text
		var function_to_call = options[button_text]
		new_btn.pressed.connect(func(): 																															# Code to check which option has been selected by the player
			if can_interact:
				hide()
				function_to_call.call()
		)
		if get_child_count() == 2:
			new_btn.grab_focus()
	show()
	await get_tree().create_timer(0.1).timeout																											# Delay for the buttons to pop out, so that the user doesn't prematurely select an option
	can_interact = true
"""==========================================================================================="""