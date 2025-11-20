extends Button

@export var scene_to_go_to : PackedScene
@export var quit = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    connect("pressed", boop)
    if not quit:
        grab_focus()


func boop():
    print("Button Boop!")
    if quit:
        get_tree().quit()
    else:
        MgrTransition.change_scene_to_pack(scene_to_go_to)