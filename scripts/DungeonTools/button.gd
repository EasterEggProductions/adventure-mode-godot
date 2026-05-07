extends DungeonObject
class_name DungeonButton

@export var connected: DungeonDoor = null
@export var depress_delay: float = 1.0
@export var one_shot: bool = false
@onready var _anim_player = $AnimationPlayer

signal on_triggered(node:DungeonButton)
signal on_release(node:DungeonButton)

const open_anim_name = "depress"
var _pressed: bool = false

func _ready() -> void:
	if connected:
		connected.register_switch(self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_activation_body_entered(body: Node3D) -> void:
	if body.is_in_group("Players") and not _pressed:
		await get_tree().create_timer(depress_delay).timeout
		_pressed = true
		emit_signal("on_triggered", self)
		notify() # notify level of state change
		
		$AnimationPlayer.play("depress")
		$aud.play(0.2)

func _on_activation_body_exited(body: Node3D) -> void:
	if body.is_in_group("Players") and not one_shot:
		await get_tree().create_timer(depress_delay).timeout
		_pressed = false
		emit_signal("on_release", self)
		notify() # notify level of state change
		
		$AnimationPlayer.play_backwards("depress")
		$aud.play(0.2)

## Dungeon object methods
func serialize() -> Dictionary:
	return {"pressed": _pressed}
	
func deserialize(state: Dictionary) -> void:
	# identical to door deserialization, perhaps the animation logic
	# could be generalized and moved up to dungeon object class somehow
	_pressed = state["pressed"]
	if _pressed:
		# seek all the way to the end of the open animation
		_anim_player.play(open_anim_name)
		_anim_player.seek(_anim_player.get_animation(open_anim_name).length, true)
