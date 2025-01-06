extends Node3D

var follow_height_offset = 1.0
var cam_follow_dist = 2.5
@export var thrall : Actor
@export var cam : Camera3D

@export var freeze = false

var velocity = Vector3.ZERO

var look_rotation_vel = Vector2.ZERO
var camLookAccell = 3.14

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if thrall == null:
		return
	var desired_pos = thrall.global_position
	desired_pos.y += follow_height_offset
	velocity = (desired_pos - global_position) * (desired_pos - global_position).length_squared()
	cam.global_position = global_position + (global_basis.z * ray_cam_pos())
	if freeze:
		return
	if velocity.length() > 10:
		velocity = velocity.normalized() * 10
		# NOTE - This is a hack, the velocity equation had a good feel too it, but went off the rails into the NaNosphere after a certain distance
	#global_position = lerp(global_position, desired_pos, 0.01)
	global_position += velocity * delta * 2#* (desired_pos - global_position).length()
	#global_position = desired_pos #velocity * delta * (desired_pos - global_position).length()
	#if Input.is_action_just_pressed("p1_look_lock"):
	#	look_at(thrall.global_position + (thrall.global_basis.z * 10))
	#cam.look_at(thrall.global_position + (Vector3.UP * 1.8))
	player_look(delta)
	

func ray_cam_pos():
	# Phys ray
	var space_state = thrall.get_world_3d().direct_space_state
	var origin = global_position
	var end = origin + (global_basis.z * cam_follow_dist)
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	#print(str(origin) + " ~ " + str(end))
	#query.collide_with_areas = true
	var col_result = space_state.intersect_ray(query)
	if "collider" in col_result.keys():
		var _dis = global_position.distance_to(col_result["position"])
		#return dis
	return cam_follow_dist


func player_look(delta):
	var disLook =  Input.get_vector("p1_look_left", "p1_look_right", "p1_look_dn", "p1_look_up")
	look_rotation_vel = disLook * delta * camLookAccell
	var default_angle = -20
	if cam.target_curr == Vector3.ZERO: # NOTE - No target
		rotate(global_basis.x, look_rotation_vel.y)
		rotate_y(-look_rotation_vel.x)
		global_rotation_degrees.x = clamp(global_rotation_degrees.x, -60,20)
	else:
		var original_rot_x = global_rotation_degrees.x
		look_at(cam.target_curr)
		global_rotation_degrees.x = original_rot_x
		#global_rotation_degrees.y = global_rotation_degrees.y #rotate_toward(original_rot_y, global_rotation_degrees.y, 50 * delta)
		default_angle = -35
	global_rotation_degrees.z = 0
	global_rotation_degrees.x += (default_angle-global_rotation_degrees.x) * 0.9 * delta
	