extends CanvasLayer
#===========================================VARIABLES============================================
@export var path_node: Line2D                                               ## The Line2D the player must follow
@export var tolerance: float = 20.0                                         ## How far the mouse can stray from the line
@export var completion_threshold: float = 0.95                              ## 0.0 to 1.0 (95% of the path finished)
@export var work_area_size: Vector2 = Vector2(360, 360)                     ## The "box" the circuit can be generated in
@export var point_count: int = 5                                            ## How many bends the wire has

var is_soldering = false
var progress = 0.0                                                          ## Tracks how far along the path the player is
var is_complete = false
"""==========================================================================================="""
@onready var container = $GameContainer
@onready var iron_tip = $GameContainer/SolderPoint
#====================================READY + PROCESS FUNCTION====================================
func _ready():
	var screen_size = get_viewport().get_visible_rect().size
	# FIX: Center the container based on the work area size
	container.position = (screen_size / 2) - (work_area_size / 2)
	
	generate_random_path()
	
	progress = 0.0
	is_complete = false

	if path_node == null:
		push_error("SolderPath (Line2D) is not assigned in the Inspector!")
"""==========================================================================================="""
func _process(_delta):
	if is_complete: return
	
	if is_soldering:
		update_solder_logic()
	else:
		progress = lerp(progress, 0.0, 0.05)
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
	
	# FIX: Maintain local coordinates for tip position
	iron_tip.position = closest_point
	
	if local_mouse.distance_to(closest_point) > tolerance:
		fail_solder()
		return
		
	# FIX: Calculate progress based on total path length for better accuracy
	var total_points = path_node.points.size()
	var current_progress = float(current_path_index) / float(total_points - 1)
	
	# If we are on the very last segment, check if we are near the final point
	if current_path_index >= total_points - 2:
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
	# Visual feedback: make the iron tip glow green
	iron_tip.modulate = Color.GREEN
	print("Circuit Restored!")
	await get_tree().create_timer(1.5).timeout
	exit_game()
"""==========================================================================================="""
func exit_game():
	queue_free()