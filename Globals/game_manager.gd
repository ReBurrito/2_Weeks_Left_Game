extends Node
#===========================================VARIABLES============================================
var current_day: int = 1
var unlocked_endings: Array[String] = []
var remaining_actions: int = 5
var max_actions: int = 5
"""==========================================================================================="""
var stats = {
	"Strength": 0,    																																							# Increased by doing physical activities
	"Knowledge": 0,      																																						# Increased by doing research activities
	"Creativity": 0,																																								# Increased by doing creative activities
	"Sociability": 0  																																							# Increased by talking to NPCs in the city
}
"""==========================================================================================="""
var flags = {}																																										# Flags to save all the events that occur at the end of each chapter
#========================================CUSTOM FUNCTIONS========================================
func add_stat(stat_name: String, amount: int):																										# Function to be called throughout the game to increase player statistics
	stats[stat_name] += amount
	print("Stat Update: ", stat_name, " is now ", stats[stat_name])
"""==========================================================================================="""
func used_object(stat_name: String, amount: int):
	if stats.has(stat_name):
		add_stat(stat_name, amount)
		spend_action()
"""==========================================================================================="""
func set_flag(flag_name: String, value: bool):
	flags[flag_name] = value
"""==========================================================================================="""
func get_flag(flag_name: String) -> bool:
	return flags.get(flag_name, false)
"""==========================================================================================="""
func advance_day():
	current_day += 1
	print("Entered day: ", current_day)
"""==========================================================================================="""
func spend_action():
	remaining_actions -= 1
	remaining_actions = max(0, remaining_actions)
"""==========================================================================================="""
func reset_actions():
	remaining_actions = max_actions
	print("Feeling refreshed! Actions reset to: ", remaining_actions)
"""==========================================================================================="""