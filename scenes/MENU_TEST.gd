extends Button

@export var scene_to_go_to : String
@export var quit = false
@export var focus = false

@export var spawn : String = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    connect("pressed", boop)
    if not quit:
        grab_focus()


func boop():
    print("Button Boop!")
    if quit:
        get_tree().quit()
    elif spawn == "":
        MgrTransition.change_scene_to_pack(load(scene_to_go_to)) 
    else:
        MgrTransition.level_transition(scene_to_go_to, spawn)
