extends Node2D

@onready var parent = get_parent().get_parent()

func _draw():
	var line_color = Color(0.4, 0.7, 1.0, 0.8)
	var start_point = Vector2(parent.lake_start_x, parent.water_level_y)
	var end_point = Vector2(parent.lake_end_x, parent.water_level_y)
	draw_line(start_point, end_point, line_color, 3.0)
	if parent.is_dragging:
		var trajectory = parent.get_trajectory_points()
		for p in trajectory:
			draw_circle(p, 1.5, Color(1, 1, 1, 0.4))
	draw_circle(parent.food_pos, 6.0, Color.ORANGE)