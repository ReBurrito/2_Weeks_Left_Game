extends CanvasLayer
#===========================================VARIABLES============================================
var game_size = Vector2(400, 400)
var bar_width = 300.0																																							## Size of the full fishing bar
var zone_width = 60.0																																							## Size of the catching zone
var fish_width = 20.0																																							## Size of the fish
var zone_pos_x = 0.0
var zone_velocity = 0.0
var zone_accel = 4000.0																																						## Fishing bar move speed
var friction = 0.9																																								## Controls reel speed
var fish_pos_x = 100.0																																						## Fish starting position
var fish_target_x = 0.0																																						## Fish target location
var fish_speed = 100.0																																						## Fish move speed
var catch_progress = 0.0
var catch_speed = 30.0  																																					## Points per second gained
var drain_speed = 15.0  																																					## Points per second lost
var is_active = true
var is_started = false
"""==========================================================================================="""
@onready var container = $GameContainer
@onready var fishing_bar = $GameContainer/FishingBar
@onready var catch_zone = $GameContainer/FishingBar/CatchZone
@onready var fish_sprite = $GameContainer/FishingBar/Fish
@onready var progress_bar = $GameContainer/FishingBar/ProgressBar
@onready var start_label = $GameContainer/StartLabel
#====================================READY + PROCESS FUNCTION====================================
func _ready():
	var screen_size = get_viewport().get_visible_rect().size																				# Center the game container
	container.position = (screen_size / 2) - (game_size / 2)
	fishing_bar.custom_minimum_size.x = bar_width																										# Code to set the size of the bar
	fishing_bar.size.x = bar_width 
	catch_zone.size.x = zone_width
	fish_sprite.size.x = fish_width
	start_label.visible = true
	var tween = create_tween().set_loops()																													# Tween to pulse the label to get the player's attention
	tween.tween_property(start_label, "modulate:a", 0.3, 0.6)
	tween.tween_property(start_label, "modulate:a", 1.0, 0.6)
"""==========================================================================================="""
func _process(delta):
	if not is_active or not is_started: return
	handle_player_input(delta)
	handle_fish_behavior(delta)
	update_progress(delta)
	update_ui()
#=======================================BUILT-IN FUNCTIONS=======================================
func _input(event):																																								# Input function to request for player engagement
	if not is_started and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			start_game()	
#========================================CUSTOM FUNCTIONS========================================
func start_game():																																								# When the game starts, turn off visibility for label and turn on visibility for the game
	is_started = true
	fishing_bar.visible = true
	start_label.visible = false
	pick_new_fish_target()
"""==========================================================================================="""
func handle_player_input(delta):																																	# Function to convert user input of left and right to move the catching zone
	var input = Input.get_axis("ui_left", "ui_right")
	var actual_bar_width = fishing_bar.size.x
	if input != 0:
		zone_velocity += input * zone_accel * delta
		zone_velocity *= friction
		zone_pos_x += zone_velocity * delta
		zone_pos_x = clamp(zone_pos_x, 0, actual_bar_width - zone_width)
		if zone_pos_x == 0 or zone_pos_x == (actual_bar_width - zone_width):
			zone_velocity = 0
"""==========================================================================================="""
func handle_fish_behavior(delta):																																	# Code for fish behaviour
	fish_pos_x = move_toward(fish_pos_x, fish_target_x, fish_speed * delta)													# Moves the fish from it's current location to the target location
	if abs(fish_pos_x - fish_target_x) < 1.0:																												# Once the fish gets close enough to the targer, the code triggers to get a new target for the fish
		pick_new_fish_target()
"""==========================================================================================="""
func pick_new_fish_target():																																			# Code to pick a new target location for the fish to travel to
	var actual_bar_width = fishing_bar.size.x
	fish_target_x = randf_range(0, actual_bar_width - fish_width)
	fish_speed = randf_range(100, 280)																															# Randomises the fish move speed to make the game more interesting
"""==========================================================================================="""
func update_progress(delta):																																			# Code to update the progress bar to indicate game progress
	var fish_mid = fish_pos_x + (fish_width / 2)
	var in_zone = fish_mid >= zone_pos_x and fish_mid <= (zone_pos_x + zone_width)									# Calculates if the fish is within the catching zone
	if in_zone:
		catch_progress += catch_speed * delta
		catch_zone.color = Color(0.4, 1.0, 0.4, 0.8)																									# Changes catch zone colour to green if the fish is in the zone
	else:
		catch_progress -= drain_speed * delta
		catch_zone.color = Color(1.0, 0.4, 0.4, 0.8)																									# Changes catch zone colour to redn if the fish is not in the zone
	catch_progress = clamp(catch_progress, 0, 100)
	progress_bar.value = catch_progress
	if catch_progress >= 100:
		win_game()
"""==========================================================================================="""
func update_ui():																																									# Code to update the UI to match the written position of the fish and catching zone
	catch_zone.position.x = zone_pos_x
	fish_sprite.position.x = fish_pos_x
"""==========================================================================================="""
func win_game():
	is_active = false
	print("You caught a memory!")
	await get_tree().create_timer(2).timeout
	exit_game()
"""==========================================================================================="""
func exit_game():
	queue_free()
"""==========================================================================================="""
