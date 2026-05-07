extends DungeonObject
class_name DungeonDoor

@export_category("Trigger config")
@export var required_switches: int = 1
@export var controlled_by_room: bool = false
@export_category("Door config")
@export var open_anim_name: String
@export var one_shot = true
@export var locked = false

@onready var _anim_player = $AnimationPlayer

var switches: Array[DungeonButton] = []
var opened: bool = false

func _ready() -> void:
	pass

func open_door():
	if not opened:
		_anim_player.play(open_anim_name)
		opened = true

func _on_switch_triggered(switch_node: DungeonButton):
	if switch_node in switches:
		switches.erase(switch_node)
	if switches.is_empty():
		open_door()

func _on_animation_finished(anim_name: StringName) -> void:
	notify()

func register_switch(switch: DungeonButton):
	switches.append(switch)
	switch.connect("on_triggered", Callable(self._on_switch_triggered))

# used for doors with open triggers
func trigger_animation(body):
	if locked or !body.is_in_group("Players"):
		return
	open_door()
	opened = true

## Dungeon object methods
func serialize() -> Dictionary:
	return {"opened": opened}

func deserialize(state: Dictionary) -> void:
	opened = state["opened"]
	if opened:
		# seek all the way to the end of the open animation
		_anim_player.play(open_anim_name)
		_anim_player.seek(_anim_player.get_animation(open_anim_name).length, true)
