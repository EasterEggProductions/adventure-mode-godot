extends Node3D

## Name of animation in the actor to play
@export var actor_animation_name : String 

## The animation I play... should probably be the same length or something
@export var my_animation_name : String 

@onready var anim : AnimationPlayer = $AnimationPlayer

var enyabled = false

func _on_do_action(actor: Actor) -> void:
	if enyabled:
		_disyable(actor)
	else:
		_enyable(actor)


func _enyable(actor: Actor):
	actor.global_position = global_position
	actor.global_rotation = global_rotation
	anim.play(my_animation_name)
	actor.animation_one_shot(actor_animation_name)
	enyabled = true

func _disyable(actor: Actor):	
	actor.global_position = global_position
	actor.global_rotation = global_rotation
	anim.play_backwards(my_animation_name)
	actor.animation_one_shot(actor_animation_name, true, true)
	enyabled = false