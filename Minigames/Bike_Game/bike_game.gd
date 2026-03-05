extends CanvasLayer

#===========================================VARIABLES============================================
@export var lane_width = 80																																				## The width of each lane, used to calculate player and obstacle positions
@export var scroll_speed = 400.0																																	## The speed at which the obstacles move down the screen
@export var spawn_rate = 1.2																																			## The time in seconds between obstacle spawns
@export var pool_size = 5																																					## The number of obstacles to keep in the pool for spawning
"""==========================================================================================="""
var bike_scene = preload("uid://b6n6prrdimdr3")																										## Preload the bike obstacle scene for use in spawning
var game_size = Vector2(400, 400)      																														## The size of the minigame window
var player_lane = 1																																								## Used to simplify the player lanes into 3 integers
var score = 0																																											## Player score, increases by 1 for every obstacle passed													
var game_active = false																																						## Used to control when the game should be processing and accepting input
var is_started = false																																						## Used to control when the game should be processing and accepting input, separate from game_active to allow for a start screen
"""==========================================================================================="""
@onready var game_container = $GameContainer
@onready var obstacle_container = $GameContainer/Obstacles
@onready var player_bike = $GameContainer/PlayerBike
@onready var score_label = $GameContainer/ScoreLabel
@onready var spawn_timer = $SpawnTimer
@onready var start_label = $GameContainer/RoadBackground/StartLabel
#====================================READY + PROCESS FUNCTION====================================
func _ready():
	var screen_size = get_viewport().get_visible_rect().size																				# 2 lines of code used to center the GameContainer to the screen
	game_container.position = (screen_size / 2) - (game_size / 2)
	prepare_obstacle_pool()																																					# Prepare the obstacle pool by instantiating a set number of obstacles and setting them to inactive
	start_label.visible = true
	var tween = create_tween().set_loops()																													# Tween to pulse the label to get the player's attention
	tween.tween_property(start_label, "modulate:a", 0.3, 0.6)
	tween.tween_property(start_label, "modulate:a", 1.0, 0.6)
"""==========================================================================================="""
func _process(delta):
	if not game_active:
		return
	var player_rect = Rect2(player_bike.global_position - Vector2(15, 25), Vector2(30, 50))					# Create a rectangle for the player bike, adjust the size as needed to fit the sprite
	for obstacle in obstacle_container.get_children():
		obstacle.position.y += scroll_speed * delta
		if obstacle is BikeObstacle:
			if player_rect.intersects(obstacle.get_rect()):																							# Checks if the player's rectangle intersects with the obstacle's rectangle.
				print("MANUAL HIT DETECTED!")
				handle_collision()
		if obstacle.get_meta("active") \
		and not obstacle.get_meta("passed") \
		and obstacle.position.y > player_bike.position.y:																							# Check if the obstacle has passed the player bike without being marked as passed, and if so, increase the score and mark it as passed
			score += 1
			score_label.text = "Score: %d" % score
			obstacle.set_meta("passed", true)
			if score % 10 == 0:
				apply_speed_up()
		if obstacle.position.y > 325:																																	# Deactivate obstacles that have moved off the bottom of the screen
			deactivate_obstacle(obstacle)
#=======================================BUILT-IN FUNCTIONS=======================================
func _input(event):
	if not is_started and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			start_game()
			return
	if Input.is_action_just_pressed("ui_accept"): # Press Space/Enter to check
		print("Player Screen Pos: ", player_bike.position)
		print("Player GLOBAL Pos: ", player_bike.global_position)
	if not game_active: return
	if event.is_action_pressed("ui_left") and player_lane > 0:																			# Converts left and right movement to single values, so that the player can move to lanes and not inbetween
		player_lane -= 1
		update_player_position()
	elif event.is_action_pressed("ui_right") and player_lane < 2:
		player_lane += 1
		update_player_position()
"""==========================================================================================="""
func _on_spawn_timer_timeout():																																		# Spawns in an obstacle after a delay
	if not game_active: return
	activate_next_obstacle()
#========================================CUSTOM FUNCTIONS========================================
func start_game():
	is_started = true
	game_active = true
	start_label.visible = false
	player_bike.position.y = 300																																		# Set the player bike to the starting y position
	update_player_position()																																				# Set the player bike to the starting lane
	player_bike.visible = true
	spawn_timer.wait_time = spawn_rate
	spawn_timer.start()
"""==========================================================================================="""
func prepare_obstacle_pool():																																			# Prepares the obstacle pool by instantiating a set number of obstacles and setting them to inactive
	for i in range(pool_size):
		var obs = bike_scene.instantiate()
		obs.visible = false
		obs.set_meta("active", false)
		obs.set_meta("passed", false)
		obs.position = Vector2(0, -100)
		obstacle_container.add_child(obs)
"""==========================================================================================="""
func activate_next_obstacle():																																		# Activates the next obstacle in the pool by setting it to active and moving it to the top of the screen in a random lane
	for obs in obstacle_container.get_children():
		if not obs.get_meta("active"):
			var lane = randi() % 3
			obs.position = Vector2((lane * lane_width) + (lane_width / 2.0), 0)
			obs.set_meta("active", true)
			obs.set_meta("passed", false)
			obs.visible = true
			return
"""==========================================================================================="""
func deactivate_obstacle(obs):																																		# Deactivates an obstacle and moves it back to the top of the screen to be reused
	obs.visible = false
	obs.set_meta("active", false)
	obs.position = Vector2(0, -100)
"""==========================================================================================="""
func handle_collision():																																					# Handles what happens when the player collides with an obstacle, in this case it ends the game and shows the final score
	game_active = false
	spawn_timer.stop()
	show_game_over()
"""==========================================================================================="""
func update_player_position():
	player_bike.position.x = (player_lane * lane_width) + (lane_width / 2.0)												# Snaps player to one of three lanes
"""==========================================================================================="""
func apply_speed_up():																																						# Increases the scroll speed and spawn rate of the obstacles to make the game more difficult as the player scores points
	create_tween().tween_property(self, "scroll_speed", scroll_speed * 1.10, 0.5)
	spawn_rate = max(0.4, spawn_rate * 0.90)
	spawn_timer.wait_time = spawn_rate
	print("SPEED UP! Current Speed: ", scroll_speed)
"""=========================================================================================="""
func show_game_over():																																						# Displays the final score and closes the game after a delay
	game_active = false
	spawn_timer.stop()
	score_label.text = "Final Score: %d" % score
	var tween = create_tween()																																			# Create tween to fade out the game to make it a smooth transition
	tween.tween_interval(2.0)																																				
	tween.tween_property(game_container, "modulate:a", 0.0, 0.5)
	tween.finished.connect(exit_game)
"""==========================================================================================="""
func exit_game():
	get_tree().paused = false
	queue_free()
"""==========================================================================================="""
