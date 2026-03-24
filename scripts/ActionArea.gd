extends Area3D
## A zone to prompt for then trigger an action. 
class_name  ActionArea

@export var message_text : String

signal do_action(actor : Actor)

func start_action(actor : Actor):
	print("Did " + message_text)
	do_action.emit(actor)
