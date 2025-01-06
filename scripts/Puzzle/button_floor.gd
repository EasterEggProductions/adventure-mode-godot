extends Node3D

@export var reset_time = 0.0 

signal on_press 
signal on_release 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_activation_body_entered(body:Node3D) -> void:
	if "player" in body.name:
		await get_tree().create_timer(1.0).timeout
		$AnimationPlayer.play("depress")
		$aud.play(0.2)
	pass # Replace with function body.


func _on_activation_body_exited(body:Node3D) -> void:
	if "player" in body.name:
		await get_tree().create_timer(1.0).timeout
		$AnimationPlayer.play_backwards("depress")
		$aud.play(0.2)
	pass # Replace with function body.
