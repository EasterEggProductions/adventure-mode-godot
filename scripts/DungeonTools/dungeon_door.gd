extends Node3D
class_name DungeonDoor

@export_category("Trigger config")
@export var required_switches: int = 1
@export var controlled_by_room: bool = false
@export_category("Door config")
@export var open_animation : String
@export var one_shot = true
@export var locked = false

@onready var _anim_player = $AnimationPlayer

var switches: Array[DungeonButton] = []
var opened = false

func _ready() -> void:
	pass

func open_door():
	if not opened:
		_anim_player.play(open_animation)
		opened = true

func _on_switch_triggered(switch_node: DungeonButton):
	if switch_node in switches:
		switches.erase(switch_node)
	if switches.is_empty():
		open_door()

func register_switch(switch: DungeonButton):
	switches.append(switch)
	switch.connect("on_triggered", Callable(self._on_switch_triggered))

# used for doors with open triggers
func trigger_animation(body):
	if locked or !body.is_in_group("Players"):
		return
	open_door()
	opened = true
