extends Node2D
#===========================================VARIABLES============================================
var textbox_scene: PackedScene = preload("uid://dc3fyce42tudr")																		# Loads the textbox scene, so that this code can use it.
var current_line = 0
var dialogue = [																																									# Dialogue that is shown in the intro, each line will make a new sentence appear in-game
	"Every step you take is a brushstroke...",
	"Every choice, a color on the canvas of your life.",
	"Where will your story lead?"
]
"""==========================================================================================="""
@onready var animation = $AnimationPlayer
#====================================READY + PROCESS FUNCTION====================================
func _ready():
	animation.play("images")																																				# Play flashback/flash-forward
	showtext()
#========================================CUSTOM FUNCTIONS========================================
func showtext():																																									# Code to make the characters in a sentence appear letter by letter
	var textbox_instance = textbox_scene.instantiate()
	add_child(textbox_instance)
	while current_line < dialogue.size():
		textbox_instance._display_text(dialogue[current_line])
		await get_tree().create_timer(4.0).timeout 
		current_line += 1
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("uid://qnmla4dedm1c")
"""==========================================================================================="""