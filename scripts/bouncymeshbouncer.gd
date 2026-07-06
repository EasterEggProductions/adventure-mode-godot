extends Node

@onready var mesh : MeshInstance3D = get_parent()
@onready var material : Material = mesh.material_override

@export var b_offpoint : Node3D

# Spring tuning
@export var stiffness := 30.0
@export var damping := 6.0
@export var max_disp := 0.15

@export var gravity = -1.5

var spring_pos := Vector3.ZERO
var spring_vel := Vector3.ZERO

func _ready() -> void:
	spring_pos = b_offpoint.global_position

func _process(delta: float) -> void:
	var target = b_offpoint.global_position
	
	# Spring force toward target
	var force = ((target - spring_pos) * stiffness) + Vector3(0,gravity,0)
	
	# Damping force
	force -= spring_vel * damping
	
	# Integrate velocity and position
	spring_vel += force * delta
	spring_pos += spring_vel * delta
	
	# Offset from target
	var offset = spring_pos - target
	
	# Clamp maximum displacement
	if offset.length() > max_disp:
		offset = offset.normalized() * max_disp
	
	material.set_shader_parameter("off_vec", offset)