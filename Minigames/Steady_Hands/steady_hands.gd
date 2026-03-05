extends CanvasLayer
#===========================================VARIABLES============================================
@export var path_node: Line2D                                               											## The Line2D the player must follow
@export var tolerance: float = 20.0                                         											## How far the mouse can stray from the line
@export var completion_threshold: float = 0.95                              											## 0.0 to 1.0 (95% of the path finished)
@export var work_area_size: Vector2 = Vector2(360, 360)                     											## The "box" the circuit can be generated in
@export var point_count: int = 5                                            											## How many bends the wire has
"""==========================================================================================="""
var is_soldering = false
var progress = 0.0                                                          											## Tracks how far along the path the player is
var is_complete = false
"""==========================================================================================="""
@onready var game_container = $GameContainer
@onready var iron_tip = $GameContainer/SolderPoint
#====================================READY + PROCESS FUNCTION====================================
func _ready():
	var screen_size = get_viewport().get_visible_rect().size
	game_container.position = (screen_size / 2) - (work_area_size / 2)																		# Center the container based on the work area size
	generate_random_path()																																					# Calls function to generate a random path for the player to trace
	progress = 0.0
	is_complete = false
	if path_node == null:
		push_error("SolderPath (Line2D) is not assigned in the Inspector!")
"""==========================================================================================="""
func _process(_delta):
	if is_complete: return																																					# Skip all the code if the path is complete
	if is_soldering:
		update_solder_logic()
	else:
		progress = lerp(progress, 0.0, 0.05)																													# Linear interpolation. Used to show the progress made by the player
#=======================================BUILT-IN FUNCTIONS=======================================
func _input(event):
	if is_complete: return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			is_soldering = event.pressed
			if is_soldering:
				check_start_position(event.position)
#========================================CUSTOM FUNCTIONS========================================
func generate_random_path():
	path_node.clear_points()
	var last_point = Vector2(0, randf_range(50, work_area_size.y - 50))
	path_node.add_point(last_point)
	var segment_width = work_area_size.x / (point_count - 1)
	for i in range(1, point_count):
		var next_x = i * segment_width
		var next_y = randf_range(20, work_area_size.y - 20)
		var elbow_point = Vector2(next_x, last_point.y)
		path_node.add_point(elbow_point)
		var final_point = Vector2(next_x, next_y)
		path_node.add_point(final_point)
		last_point = final_point
	print("New Circuit Layout Generated!")
"""==========================================================================================="""
func check_start_position(mouse_pos):
	var start_point = path_node.to_global(path_node.points[0])
	if mouse_pos.distance_to(start_point) > tolerance * 2:
		is_soldering = false
"""==========================================================================================="""
func update_solder_logic():
	var mouse_pos = get_viewport().get_mouse_position()
	var local_mouse = path_node.to_local(mouse_pos)
	var result = get_closest_point_on_path(local_mouse)
	var closest_point = result[0]
	var current_path_index = result[1]
	iron_tip.position = closest_point
	if local_mouse.distance_to(closest_point) > tolerance:
		fail_solder()
		return
	var total_points = path_node.points.size()
	var current_progress = float(current_path_index) / float(total_points - 1)
	if current_path_index >= total_points - 2:																											# Checking for the distance to the final point
		var last_p = path_node.points[total_points - 1]
		if closest_point.distance_to(last_p) < tolerance:
			current_progress = 1.0
	if current_progress > progress:
		progress = current_progress
	if progress >= completion_threshold:
		complete_circuit()
"""==========================================================================================="""
func get_closest_point_on_path(point: Vector2):
	var closest_p = path_node.points[0]
	var best_dist = 1e10
	var segment_index = 0
	for i in range(path_node.points.size() - 1):
		var p1 = path_node.points[i]
		var p2 = path_node.points[i+1]
		var seg_v = p2 - p1
		var pt_v = point - p1
		var t = clamp(pt_v.dot(seg_v) / seg_v.length_squared(), 0.0, 1.0)
		var closest = p1 + seg_v * t
		var d = point.distance_to(closest)
		if d < best_dist:
			best_dist = d
			closest_p = closest
			segment_index = i
	return [closest_p, segment_index]
"""==========================================================================================="""
func fail_solder():
	is_soldering = false
	progress = 0.0
	print("Connection broken!")
"""==========================================================================================="""
func complete_circuit():
	is_complete = true
	iron_tip.modulate = Color.GREEN
	print("Circuit Restored!")
	var tween = create_tween()
	tween.tween_interval(2.0)																																				# Tween timer to allow the player to admire the painting.
	tween.tween_property(game_container, "modulate:a", 0.0, 0.5)
	tween.finished.connect(exit_game)
"""==========================================================================================="""
func exit_game():
	get_tree().paused = false
	queue_free()
"""==========================================================================================="""