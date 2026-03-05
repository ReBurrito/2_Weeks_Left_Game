extends Area2D
class_name BikeObstacle

# Adjust these numbers to match the actual size of your bike sprite
# If the bike is 32x64, use Vector2(32, 64)
@export var collision_size = Vector2(30, 50) 

func get_rect() -> Rect2:
    # This creates a mathematical rectangle centered on the bike
    return Rect2(global_position - (collision_size / 2.0), collision_size)