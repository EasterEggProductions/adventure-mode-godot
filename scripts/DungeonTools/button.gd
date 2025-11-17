extends Node3D
class_name DungeonButton

@export var connected: DungeonDoor = null
@export var depress_delay: float = 1.0
@export var one_shot: bool = false

signal on_triggered(node:DungeonButton)
signal on_release(node:DungeonButton)

var _pressed = false

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
		$AnimationPlayer.play("depress")
		$aud.play(0.2)

func _on_activation_body_exited(body: Node3D) -> void:
	if body.is_in_group("Players") and not one_shot:
		await get_tree().create_timer(depress_delay).timeout
		_pressed = false
		emit_signal("on_release", self)
		$AnimationPlayer.play_backwards("depress")
		$aud.play(0.2)
