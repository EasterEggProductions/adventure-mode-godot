extends Node3D
class_name DungeonDoor

@onready var _anim_player = $AnimationPlayer

@export var animation : String
@export var one_shot = true
@export var locked = false

var opened = false 

func _init() -> void:
	pass

func open_door():
	if not opened:
		_anim_player.play(animation)
		opened = true

func register_switch(switch: DungeonButton):
	switch.connect("on_triggered", Callable(self.open_door))

func trigger_animation(body):
	if locked or !body.is_in_group("Players"):
		return
	open_door()
	opened = true
