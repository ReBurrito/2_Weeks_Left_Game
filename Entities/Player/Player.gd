extends CharacterBody2D
#===========================================VARIABLES============================================
@export var speed = 200.0																																					## How fast the player character moves in the game
@export var friction = 1000.0																																			## This will determine how fast the player will slow down to a complete stop
@export var acceleration = 800.0																																	## This determines how fast the player will reach max speed
"""==========================================================================================="""
var current_interactable = null
var tween: Tween 
"""==========================================================================================="""
@onready var interact_prompt = $InteractPrompt
@onready var playerSprite = $PlayerSprite
#====================================READY + PROCESS FUNCTION====================================
func _physics_process(delta: float) -> void:
	var menu = get_tree().current_scene.find_child("ChoiceMenu")																		## Locates the child node to display options for interactable objects
	if menu and menu.visible:																																				# Checks to see if an object has been interacted with or not. (visible means an object has been interacted with)
		return
	var direction = Input.get_axis("ui_left", "ui_right")																						
	if direction:																																										# Flips sprite depending on direction of movement
		velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
		playerSprite.flip_h = direction < 0																														
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)
	move_and_slide()																																								# Moves the sprite according to the results above
#=======================================BUILT-IN FUNCTIONS=======================================
func _input(event):																																								# Code to interact with object
	if event.is_action_pressed("ui_accept") and current_interactable:
		if current_interactable.has_method("sleep"):
			current_interactable.interact()
			return
		if GameManager.remaining_actions <= 0:
			show_tired_reminder()
		else:
			current_interactable.interact()
"""==========================================================================================="""
func _on_interactable_area_area_entered(area: Area2D):																						# Checks for interactable objects when the player moves close enough to the object
	if area.has_method("interact"):
		current_interactable = area
		show_prompt()
"""==========================================================================================="""
func _on_interactable_area_area_exited(area: Area2D):																							# Hides the interact prompt when the player leaves the interactable object
	if current_interactable == area:
		current_interactable = null
		hide_prompt()
#========================================CUSTOM FUNCTIONS========================================
func show_prompt():																																								# Code to help animate the reveal of the intereact prompt
	if tween: tween.kill()
	interact_prompt.show()
	tween = create_tween()
	tween.tween_property(interact_prompt, "modulate:a", 1.0, 0.2)
	tween.parallel().tween_property(interact_prompt, "position:y", -200, 0.2).from(-145)
"""==========================================================================================="""
func hide_prompt():																																								#Code to animate the interact prompt being hidden away
	if tween: tween.kill()
	tween = create_tween()
	tween.tween_property(interact_prompt, "modulate:a", 0.0, 0.2)
	tween.parallel().tween_property(interact_prompt, "position:y", -145, 0.2).from(-200)
	tween.tween_callback(interact_prompt.hide)
"""==========================================================================================="""
func show_tired_reminder():
	print("I'm too exhausted to do this... I should find a place to sleep.")
	var flash_tween = create_tween()
	flash_tween.tween_property(interact_prompt, "modulate", Color.RED, 0.1)
	flash_tween.tween_property(interact_prompt, "modulate", Color.WHITE, 0.1)
"""==========================================================================================="""