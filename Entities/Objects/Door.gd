extends Interactable
#========================================CUSTOM FUNCTIONS========================================
func get_choices() -> Dictionary:
	return {
		"It's boring here, let's leave.": leave_house,
		"Not yet...": leave_object
	}
"""==========================================================================================="""
func leave_house():
	print("Change scene here")

func leave_object():
	print("Maybe later.")
"""==========================================================================================="""