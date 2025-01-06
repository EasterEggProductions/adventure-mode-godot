extends Node3D

@export var animator : AnimationPlayer
@export var animation : String
@export var one_shot = true
var shot = false 
@export var locked = false

func trigger_animation(nothing):
	if locked:
		return
	# Dirty check for player 
	print(name)
	if !nothing.is_in_group("players"):
		return
	if one_shot == false:
		animator.play(animation)
	elif shot == false:
		shot = true
		animator.play(animation) 