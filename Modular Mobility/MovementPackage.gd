extends Resource

class_name MovementPackage

@export var name : String
@export var anim_tree : AnimationRootNode

@export var anim_library : AnimationLibrary


func apply():
	pass

func transfer_situation_check(_thrall : Actor) -> bool:
	printerr("ERROR - Abstract method")
	return false # We are abstract kinda, always not be here

func release_situation_check(_thrall : Actor) -> bool:
	printerr("ERROR - Abstract method")
	return true # We are abstract kinda, always not be here

func move_thrall(_thrall : Actor, _delta : float):
	printerr("ERROR - Abstract method")
	pass