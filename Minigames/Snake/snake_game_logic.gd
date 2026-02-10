extends Node2D

@onready var main = get_parent().get_parent()

func _draw():
	for i in range(main.snake.size()):
		var color = Color.GREEN if i == 0 else Color.DARK_GREEN
		draw_rect(Rect2(main.snake[i] * main.grid_size, Vector2(main.grid_size, main.grid_size)), color)
	draw_rect(Rect2(main.food * main.grid_size, Vector2(main.grid_size, main.grid_size)), Color.RED)