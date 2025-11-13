extends Node3D
class_name DungeonDoor

@onready var _anim_player = $AnimationPlayer

@export var animation : String
@export var one_shot = true
@export var locked = false

var _opened = false 

func _init() -> void:
	pass

func open_door():
	if not _opened:
		_anim_player.play(animation)
		_opened = true

# bad name
func register_interactable(interactable: DungeonButton):
	interactable.connect("on_triggered", Callable(self.open_door))

#func _on_interactable_triggered():
	
func trigger_animation(body):
	if locked:
		return
	# Dirty check for player 
	print(name)
	if !body.is_in_group("Players"):
		return
	if one_shot == false:
		open_door()
	elif _opened == false:
		_opened = true
		open_door()
