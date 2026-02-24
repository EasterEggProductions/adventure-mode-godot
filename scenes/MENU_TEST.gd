extends Button

@export var scene_to_go_to : PackedScene
@export var quit = false
@export var focus = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("pressed", boop)
	if focus:
		grab_focus()


func boop():
	print("Button Boop!")
	if quit:
		get_tree().quit()
	elif spawn == "":
		MgrTransition.change_scene_to_pack(load(scene_to_go_to)) 
	else:
		MgrTransition.level_transition(scene_to_go_to, spawn)
