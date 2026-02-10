extends CanvasLayer
#===========================================VARIABLES============================================
var grid_size = 20																																								## In terms of pixels, how big is each square of the board
var cells = Vector2(16, 16) 																																			## How big the map is
var snake = [Vector2(5, 10), Vector2(4, 10), Vector2(3, 10)]																			## Location of the snake
var direction = Vector2.RIGHT																																			## Starting direction of the snake
var next_direction = Vector2.RIGHT
var food = Vector2.ZERO
var score = 0
"""==========================================================================================="""
@onready var timer = $GameContainer/SnakeGameLogic/MoveTimer
@onready var game_over_btn = $GameContainer/GameOverButton
@onready var final_score = $GameContainer/GameOverButton/Score
@onready var snake_logic_node = $GameContainer/SnakeGameLogic
#====================================READY + PROCESS FUNCTION====================================
func _ready():
	var screen_size = get_viewport().get_visible_rect().size
	var grid_pixels = cells * grid_size
	$GameContainer.position = (screen_size / 2) - (grid_pixels / 2)
	place_food()
	timer.timeout.connect(_on_move_timer_timeout)
#=======================================BUILT-IN FUNCTIONS=======================================
func _input(event):																																								# Code to determine input directions and the direction of travel for the snake
	if event.is_action_pressed("ui_up") and direction != Vector2.DOWN:
		next_direction = Vector2.UP
	elif event.is_action_pressed("ui_down") and direction != Vector2.UP:
		next_direction = Vector2.DOWN
	elif event.is_action_pressed("ui_left") and direction != Vector2.RIGHT:
		next_direction = Vector2.LEFT
	elif event.is_action_pressed("ui_right") and direction != Vector2.LEFT:
		next_direction = Vector2.RIGHT
"""==========================================================================================="""
func _on_move_timer_timeout():
	direction = next_direction
	var head = snake[0] + direction
	if head.x < 0 or head.x >= cells.x or head.y < 0 or head.y >= cells.y or head in snake:					# If the snake head touches the border or snake head touches a snake part, end the game
		show_game_over()
		return
	snake.insert(0, head)																																						# Place the snake head in the target direction if the game continues
	if head == food:																																								# If the snake head is on a food square, increase the score by 1 and place a new food
		score += 1
		place_food()
	else:
		snake.pop_back()																																							# If no food token has been claimed, remove the last part of the snake
	snake_logic_node.queue_redraw()
"""==========================================================================================="""
func _on_game_over_button_pressed():
	exit_game()
#========================================CUSTOM FUNCTIONS========================================
func place_food():
	food = Vector2(randi() % int(cells.x), randi() % int(cells.y))																	# Uses randomizer to spawn in food
	while food in snake:																																						# Loops the function until the food isn't spawned on top of a snake part
		food = Vector2(randi() % int(cells.x), randi() % int(cells.y))
"""==========================================================================================="""
func show_game_over():
	timer.stop()
	game_over_btn.visible = true
	final_score.text = "Score: %d" % score
"""==========================================================================================="""
func exit_game():
	get_tree().paused = false
	queue_free()
"""==========================================================================================="""
