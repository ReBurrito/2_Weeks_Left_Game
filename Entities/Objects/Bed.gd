extends Interactable
#========================================CUSTOM FUNCTIONS========================================
func get_choices() -> Dictionary:																																	# Updates the dictionary from the Interactable base script so that each interactable has their own options
	return {
		"Time for bed.": sleep,
		"Not yet...": leave_object
	}
"""==========================================================================================="""
func sleep():																																											# Adding function to each option (will increase stats based on which choices have been selected)
	print("Goodnight bbg.")
	GameManager.reset_actions()
	if GameManager.current_day > 1:
		GameManager.advance_day()
"""==========================================================================================="""
func leave_object():
	print("Maybe later.")
"""==========================================================================================="""