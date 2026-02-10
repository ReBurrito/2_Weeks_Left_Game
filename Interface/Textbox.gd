extends MarginContainer
#===========================================VARIABLES============================================
const MAX_WIDTH: int  = 800																																				## Max width of the textbox for the dialogue to appear in
var letter_time: float = 0.05																																			## Different time determines the pause length per letter that appears
var space_time: float = 0.05																																			## Different time determines the pause length per space that appears
var punctuation_time: float = 0.1																																	## Different time determines the pause length per punctuation that appears
"""==========================================================================================="""
@onready var label: Label = $MarginContainer/Label
@onready var timer: Timer = $LetterDisplayTimer
#========================================CUSTOM FUNCTIONS========================================
func _display_text(text_to_display: String) -> void:																							# Function to breakdown a dialog to letters 
	timer.stop()
	label.text = text_to_display
	label.visible_characters = 0
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	label.custom_minimum_size.x = MAX_WIDTH
	await get_tree().process_frame
	_display_letter()
"""==========================================================================================="""
func _display_letter():																																						# Function to display the sentence letter by letter, so it seems like the character is talking.
	if label.visible_characters >= label.get_total_character_count():
		return
	label.visible_characters += 1
	var current_char = label.text[label.visible_characters - 1]
	match current_char:
		"!", ".", ",", "?":
			timer.start(punctuation_time)
		" ":
			timer.start(space_time)
		_:
			timer.start(letter_time)
"""==========================================================================================="""
func _on_letter_display_timer_timeout():
	_display_letter()
"""==========================================================================================="""