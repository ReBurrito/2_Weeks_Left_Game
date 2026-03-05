extends CanvasLayer
#===========================================VARIABLES============================================
@export var memories: Array[Texture2D] = []                                                       ## Pool of images the player can "tune" into
@export var hold_duration: float = 1.0                                                            ## How long to hold the dial to lock the signal
var current_memory_index = 0
var target_angle = 0.0
var tolerance = 5.0                                                                               ## Success window in degrees
var visual_tolerance = 45.0                                                                       ## Range where static begins to clear
var is_locked = false
var is_dragging = false
var current_hold_time = 0.0
"""===============================	============================================================"""
@onready var static_rect = $GameContainer/StaticOverlay
@onready var dial = $GameContainer/TuningDial
@onready var hidden_image = $GameContainer/HiddenImage
@onready var game_container = $GameContainer
#====================================READY + PROCESS FUNCTION====================================
func _ready():
	var screen_size = get_viewport().get_visible_rect().size
	game_container.position = (screen_size / 2)																											# This + Line above is sued to center the game to the screen
	if memories.size() > 0:
		current_memory_index = randi() % memories.size()																							# Selects a random image from the index
		hidden_image.texture = memories[current_memory_index]
	target_angle = randf_range(0, 360)																															# Sets the target angle for the player to guess
	static_rect.material.set_shader_parameter("noise_intensity", 1.0)																# Applies a static rectangle over the image to simulate noise
"""==========================================================================================="""
func _process(delta):
	if is_locked: return																																						# If the signal is clear, ignore rest of the code
	if is_dragging:
		update_dial_rotation()
	var angle_diff = abs(angle_difference_deg(dial.rotation_degrees, target_angle))
	if angle_diff < tolerance:																																			# Handle the "Holding" logic for signal locking
		current_hold_time += delta
		if current_hold_time >= hold_duration:
			complete_tuning()
	else:
		current_hold_time = 0.0
	var intensity = clamp(angle_diff / visual_tolerance, 0.0, 1.0)
	static_rect.material.set_shader_parameter("noise_intensity", intensity)
#=======================================BUILT-IN FUNCTIONS=======================================
func _input(event):
	if is_locked: return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			is_dragging = event.pressed
#========================================CUSTOM FUNCTIONS========================================
func update_dial_rotation():																																			# Function used to update and rotate the dial thhrough user input
	var mouse_pos = get_viewport().get_mouse_position()
	var direction_vec = mouse_pos - (game_container.global_position + dial.position)
	dial.rotation_degrees = rad_to_deg(direction_vec.angle())
"""==========================================================================================="""
func angle_difference_deg(from, to):
	return fposmod(to - from + 180, 360) - 180
"""==========================================================================================="""
func complete_tuning():
	is_locked = true																																								# Upon winning the game, the dial will be locked
	dial.rotation_degrees = target_angle
	static_rect.material.set_shader_parameter("noise_intensity", 0.0)																# Disables the "noise" mesh
	print("Memory Found: Signal Locked!")
	var tween = create_tween()
	tween.tween_interval(2.0)																																				# Tween timer to allow the player to admire the painting.
	tween.tween_property(game_container, "modulate:a", 0.0, 0.5)
	tween.finished.connect(exit_game)
"""==========================================================================================="""
func exit_game():
	get_tree().paused = false
	queue_free()
"""==========================================================================================="""