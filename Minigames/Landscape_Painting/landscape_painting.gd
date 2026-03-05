extends CanvasLayer
#===========================================VARIABLES============================================
var game_size = Vector2(400, 400)
var is_painting = false
var stroke_step = 0																																								## Helps show which stage the painting is at
var current_target_start = Vector2(100, 300)																											## Determines the starting point of the current stroke
var current_target_end = Vector2(400, 100)																												## Determines the end point of the current stroke
var threshold = 60.0 
"""==========================================================================================="""
@onready var game_container = $GameContainer
@onready var visual_stroke = $GameContainer/StrokeLine
@onready var hidden_image = $GameContainer/LandscapeImage
@onready var prompt_label = $GameContainer/PromptLabel
@onready var guide_line = $GameContainer/GuideLine
"""==========================================================================================="""
var landscape_steps = [																																						## Used to determine the location and the number of strokes needed to finish the painting
	{"start": Vector2(50, 350), "end": Vector2(350, 350), "msg": "Sketch the horizon..."},
	{"start": Vector2(250, 350), "end": Vector2(250, 100), "msg": "Build the city skyline..."},
	{"start": Vector2(50, 50), "end": Vector2(350, 200), "msg": "Let the sunset bleed in..."}
]
#====================================READY + PROCESS FUNCTION====================================
func _ready():
	var screen_size = get_viewport().get_visible_rect().size																				# Code to help center the game container to the center of the screen
	game_container.position = (screen_size / 2) - (game_size / 2)
	appear_animation()
	setup_stroke(0)
#=======================================BUILT-IN FUNCTIONS=======================================
func _input(event):																																								# Input event used to track where on the screen is the painting happening 
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			var mouse_local = event.position - game_container.global_position
			if event.pressed:																																						# If statements to determine if the game needs to procceed to the next stage
				if mouse_local.distance_to(current_target_start) < threshold:
					is_painting = true
					visual_stroke.clear_points()
			else:
				if is_painting and mouse_local.distance_to(current_target_end) < threshold:
					complete_stroke()
				is_painting = false
				visual_stroke.clear_points()
	if event is InputEventMouseMotion and is_painting:
		visual_stroke.add_point(event.position - game_container.global_position)
#========================================CUSTOM FUNCTIONS========================================
func appear_animation():																																					# Function used to give a smooth transition to the game appearing
	var tween = create_tween().set_parallel(true)
	tween.tween_property(game_container, "modulate:a", 1.0, 0.5)
	tween.tween_property(game_container, "scale", Vector2(1, 1), 0.5)\
	.set_trans(Tween.TRANS_BACK)\
	.set_ease(Tween.EASE_OUT)
"""==========================================================================================="""
func setup_stroke(index):																																					# Function used to set up the current stroke to be drawn by the player
	if index < landscape_steps.size():
		var data = landscape_steps[index]
		current_target_start = data["start"]
		current_target_end = data["end"]
		prompt_label.text = data["msg"]
		draw_guide(current_target_start, current_target_end)
	else:
		guide_line.clear_points()
		finish_and_close()
"""==========================================================================================="""
func draw_guide(start: Vector2, end: Vector2):																										# Using the setup points to draw guide lines for the player to follow to complete the painting steps
	guide_line.clear_points()
	guide_line.add_point(start)
	guide_line.add_point(end)
	guide_line.modulate.a = 0
	guide_line.visible = true
	var t = create_tween()
	t.tween_property(guide_line, "modulate:a", 0.3, 0.5)
"""==========================================================================================="""
func complete_stroke():																																						# Function used to slowly modulate the image to a full coloured painting after each painting stroke is completed
	guide_line.visible = false
	stroke_step += 1
	var total_steps = landscape_steps.size()
	var target_alpha = float(stroke_step) / total_steps
	var reveal_tween = create_tween()
	reveal_tween.tween_property(hidden_image, "modulate:a", target_alpha, 1.2)\
	.set_trans(Tween.TRANS_SINE)\
	.set_ease(Tween.EASE_IN_OUT)
	await reveal_tween.finished
	setup_stroke(stroke_step)
"""==========================================================================================="""
func finish_and_close():																																					# When the painting is done, wait a few seconds before closing the game
	prompt_label.text = "Everything is clear now."
	var tween = create_tween()
	tween.tween_interval(2.0)																																				# Tween timer to allow the player to admire the painting.
	tween.tween_property(game_container, "modulate:a", 0.0, 0.5)
	tween.finished.connect(exit_game)
"""==========================================================================================="""
func exit_game():
	get_tree().paused = false
	queue_free()
"""==========================================================================================="""