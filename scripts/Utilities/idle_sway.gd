extends Node3D
@export var wavelength : Vector3 = Vector3(0.1,0.1,0.1)
@export var amplitude : Vector3 = Vector3(0.5,0.5,0.5)

@export var node : Node3D

func _ready() -> void:
	$Camera3D/Amode_Title/AnimationPlayer.play("sword of godot _finalAction")

func _process(_delta: float) -> void:
	sway()

func sway() -> void:
	
	var x : float =  (sin(Time.get_ticks_msec() *(wavelength.x * 0.01)) * amplitude.x - (amplitude.x / 2))
	var y : float =  (sin(Time.get_ticks_msec() *(wavelength.y * 0.01)) * amplitude.y - (amplitude.y / 2))
	var z : float =  (sin(Time.get_ticks_msec() *(wavelength.z * 0.01)) * amplitude.z - (amplitude.z / 2))
	#rect_scale = Vector2(1 + oscilio, 1 + oscilio)
	node.position = Vector3(x,y,z)