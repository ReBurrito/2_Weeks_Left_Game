extends CanvasLayer
#===========================================VARIABLES============================================
var game_size = Vector2(400, 400)      																														## The size of the minigame window
var launch_origin = Vector2(75, 250)  																														## The "slingshot" anchor point
var water_level_y = 320.0             																														## The Y-coordinate of the water surface
var lake_start_x = 200.0              																														## Where the "active" feeding part of the lake begins
var lake_end_x = 380.0                																														## Where the "active" feeding part of the lake ends
var food_pos = launch_origin
var food_velocity = Vector2.ZERO
var is_dragging = false
var is_flying = false
var gravity = 400.0                    																														## Strength of gravity pulling food down
var score = 0
var attempts = 0
"""==========================================================================================="""
@onready var game_container = $GameContainer
@onready var game_logic_node = $GameContainer/FishGameLogic
@onready var game_over_btn = $GameContainer/GameOverButton
@onready var final_score = $GameContainer/GameOverButton/Score
#====================================READY + PROCESS FUNCTION====================================
func _ready():
	var screen_size = get_viewport().get_visible_rect().size
	game_container.position = (screen_size / 2) - (game_size / 2)
	food_pos = launch_origin
"""==========================================================================================="""
func _process(delta):
	if is_flying:
		food_velocity.y += gravity * delta
		food_pos += food_velocity * delta
		if (food_pos.x >= 400) or (food_pos.x <= 0):
			reset_food()
		if food_pos.y >= water_level_y:																																# Check if food has hit the surface of the water
			if food_pos.x >= lake_start_x and food_pos.x <= lake_end_x:
				hit_target()
			else:
				reset_food()

		game_logic_node.queue_redraw()
#=======================================BUILT-IN FUNCTIONS=======================================
func _input(event):
	if is_flying: return																															 							# Can't drag while one is in the air
	if event is InputEventMouseButton:
		var local_mouse = event.position - game_container.global_position
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and local_mouse.distance_to(launch_origin) < 30:
				is_dragging = true
			elif is_dragging and not event.pressed:
				launch_food(local_mouse)
	if event is InputEventMouseMotion and is_dragging:
		var local_mouse = event.position - game_container.global_position
		var dir = local_mouse - launch_origin
		if dir.length() > 75:																																				# Limit drag distance
			dir = dir.normalized() * 75
		food_pos = launch_origin + dir
		game_logic_node.queue_redraw()
"""==========================================================================================="""
func _on_game_over_button_pressed():
	exit_game()
#========================================CUSTOM FUNCTIONS========================================
func launch_food(_mouse_pos):
	is_dragging = false
	is_flying = true
	attempts += 1
	var drag_vector = food_pos - launch_origin																											# Launch in the opposite direction of the drag
	food_velocity = -drag_vector * 6.0
"""==========================================================================================="""
func hit_target():
	score += 1
	reset_food()
"""==========================================================================================="""
func reset_food():
	if attempts >= 5:																																								# Game ends after 5 attempts
		show_game_over()
	else:
		is_flying = false
		food_pos = launch_origin
		food_velocity = Vector2.ZERO
		game_logic_node.queue_redraw()
"""==========================================================================================="""
func show_game_over():
	is_flying = false
	game_over_btn.visible = true
	final_score.text = "Fish Fed: %d" % score
"""==========================================================================================="""
func get_trajectory_points() -> PackedVector2Array:
	var points = PackedVector2Array()
	if not is_dragging:
		return points
	var drag_vector = food_pos - launch_origin
	var sim_velocity = -drag_vector * 6.0
	var sim_pos = launch_origin
	var simulation_time = 0.6 
	var step = 0.05
	var t = 0.0
	while t < simulation_time:
		var x = sim_pos.x + (sim_velocity.x * t)
		var y = sim_pos.y + (sim_velocity.y * t) + (0.5 * gravity * t * t)														# Kinematic equation: position = start + (velocity * time) + (0.5 * gravity * time^2)
		points.append(Vector2(x, y))
		t += step
	return points
"""==========================================================================================="""
func exit_game():
	get_tree().paused = false
	queue_free()
"""==========================================================================================="""
