extends CanvasLayer
#===========================================VARIABLES============================================
@export var puzzle_image: Texture2D                                         											## The image to be sliced into pieces
@export var grid_size: int = 4                                              											## 4x4 for a 15-puzzle, 3x3 for an 8-puzzle
@export var slide_duration: float = 0.15                                    											## Speed of the sliding animation
"""==========================================================================================="""
var tiles = []                                                              											## Array to track tile objects
var empty_tile_pos: Vector2i                                                											## Coordinates of the blank space
var is_shuffling = false
var is_solved = false
"""==========================================================================================="""
@onready var game_container = $GameContainer
@onready var tile_parent = $GameContainer/TileHolder                       												# A Control/Node2D to hold the pieces
#====================================READY + PROCESS FUNCTION====================================
func _ready():
	var screen_size = get_viewport().get_visible_rect().size
	var puzzle_total_size = puzzle_image.get_size() 
	game_container.position = (screen_size / 2) - (puzzle_total_size / 2)
	create_puzzle()
	shuffle_puzzle()
"""==========================================================================================="""
func _process(_delta):
	if is_solved or is_shuffling: return
	if check_win_condition():
		complete_puzzle()
#=======================================BUILT-IN FUNCTIONS=======================================
func _input(event):
	if is_solved or is_shuffling: return
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			handle_tile_click(get_viewport().get_mouse_position())
#========================================CUSTOM FUNCTIONS========================================
func create_puzzle():                                                        											# Slices the texture into interactive tiles
	var tile_size = puzzle_image.get_size() / grid_size
	empty_tile_pos = Vector2i(grid_size - 1, grid_size - 1)
	
	for y in range(grid_size):
		for x in range(grid_size):
			if x == empty_tile_pos.x and y == empty_tile_pos.y:
				tiles.append(null) 																																				# The "Empty" slot
				continue
			var new_tile = TextureRect.new()
			new_tile.texture = puzzle_image
			new_tile.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			new_tile.custom_minimum_size = tile_size
			new_tile.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED																		# Setup the Atlas/Region to show only a piece of the image
			var atlas = AtlasTexture.new()
			atlas.atlas = puzzle_image
			atlas.region = Rect2(Vector2(x, y) * tile_size, tile_size)
			new_tile.texture = atlas
			tile_parent.add_child(new_tile)
			new_tile.position = Vector2(x, y) * tile_size
			new_tile.set_meta("correct_pos", Vector2i(x, y))
			new_tile.set_meta("current_pos", Vector2i(x, y))
			tiles.append(new_tile)
"""==========================================================================================="""
func handle_tile_click(mouse_pos):                                           											# Logic to swap tiles with the empty space
	for tile in tile_parent.get_children():
		if tile.get_global_rect().has_point(mouse_pos):
			var current_pos = tile.get_meta("current_pos")
			if is_adjacent(current_pos, empty_tile_pos):
				swap_tiles(tile, current_pos)
"""==========================================================================================="""
func is_adjacent(pos1: Vector2i, pos2: Vector2i) -> bool:
	var diff = (pos1 - pos2).abs()
	return (diff.x + diff.y) == 1
"""==========================================================================================="""
func swap_tiles(tile, tile_pos):                                            											# Moves the tile visually and logically
	var target_pos = Vector2(empty_tile_pos) * tile.custom_minimum_size
	var tween = create_tween()
	tween.tween_property(tile, "position", target_pos, slide_duration)															# Tween for smooth sliding
	var temp_pos = empty_tile_pos																																		# Update logic coordinates
	empty_tile_pos = tile_pos
	tile.set_meta("current_pos", temp_pos)
"""==========================================================================================="""
func shuffle_puzzle():                                                       											# Performs random valid moves to shuffle
	is_shuffling = true
	for i in range(100):																																						# To ensure solvability, we simulate random valid moves rather than randomizing array
		var movable_tiles = []
		for tile in tile_parent.get_children():
			if is_adjacent(tile.get_meta("current_pos"), empty_tile_pos):
				movable_tiles.append(tile)
		var random_tile = movable_tiles[randi() % movable_tiles.size()]
		swap_tiles(random_tile, random_tile.get_meta("current_pos"))
		await get_tree().create_timer(0.01).timeout
	is_shuffling = false
	tile_parent.visible = true
"""==========================================================================================="""
func check_win_condition() -> bool:
	for tile in tile_parent.get_children():
		if tile.get_meta("current_pos") != tile.get_meta("correct_pos"):
			return false
	return true
"""==========================================================================================="""
func complete_puzzle():
	is_solved = true
	print("Memory Restored: Puzzle Solved!")
	var tween = create_tween()
	tween.tween_interval(2.0)																																				# Tween timer to allow the player to admire the painting.
	tween.tween_property(game_container, "modulate:a", 0.0, 0.5)
	tween.finished.connect(exit_game)
"""==========================================================================================="""
func exit_game():
	get_tree().paused = false
	queue_free()
"""==========================================================================================="""
