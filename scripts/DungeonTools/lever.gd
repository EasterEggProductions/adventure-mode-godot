extends DungeonObject

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
	enyabled = true
	actor.global_position = global_position
	actor.global_rotation = global_rotation
	actor.anim_hide_weapons()
	anim.play(my_animation_name)
	actor.animation_tree.active = false
	var a_anim : AnimationPlayer = actor.animation_tree.get_node(actor.animation_tree.anim_player) 
	a_anim.play(actor_animation_name) 
	await a_anim.animation_finished
	actor.anim_show_weapons()
	actor.animation_tree.active = true

func _disyable(actor: Actor):	
	enyabled = false
	actor.global_position = global_position
	actor.global_rotation = global_rotation
	actor.anim_hide_weapons()
	anim.play_backwards(my_animation_name)
	actor.animation_tree.active = false
	var a_anim : AnimationPlayer = actor.animation_tree.get_node(actor.animation_tree.anim_player) 
	a_anim.play_backwards(actor_animation_name) 
	await a_anim.animation_finished
	actor.anim_show_weapons()
	actor.animation_tree.active = true

func _on_animation_finished(anim_name: StringName) -> void:
	notify()

func serialize() -> Dictionary:
	return {"enabled": enyabled}
	
func deserialize(state: Dictionary) -> void:
	enyabled = state["enabled"]
	if enyabled:
		anim.play(my_animation_name)
		anim.seek(anim.get_animation(my_animation_name).length, true)
