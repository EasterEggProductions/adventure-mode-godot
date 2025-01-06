extends Camera3D

@export var target_current : Node3D
@export var distance = 5.0
var distance_to_target: float
@export var zoom_min : float  
@export var zoom_max : float 
@export var zoom_target = 1
@export var zoom_speed = 0.4
@export var cam_sens = 0.05
var fov_value = 75
var follow_speed = 5.0
var prev_mouse_pos = Vector2.ZERO
var radius = 4.0
var target_curr = Vector3.ZERO
var new_position = Vector3.ZERO
var mox = 0 
var smoothing = 0.1 

# SECTION New shit
var cam_velocity = Vector3.ZERO
var leash_dist_current = 3.0
var follow_offset = Vector3(0, 2.3, 0)
@export var look_offset_screen_percent = 0.9

var cam_rot_velocity = Vector2.ZERO

var camLookSpeed = 2
var camLookAccell = 5
var camLookVel = Vector3.ZERO

@export var freeze = false


@export var offsetty = 800

func _ready():
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#prev_mouse_pos = get_viewport().get_mouse_position() 
	pass

# NOTE - _physics causes jitter, but _process causes a strange bug that looks at your feet on 144hz monitor
func _physics_process(delta: float) -> void:

	if is_instance_valid(target_current) == false: # Guard clause style, baby!
		return 
	if freeze:
		return

	_look(delta)

func _follow(delta):
	var dir_to_target = (target_current.global_position + follow_offset) - global_position
	var dist_beyond_leash = leash_dist_current - dir_to_target.length()
	dist_beyond_leash = dist_beyond_leash**2 if dist_beyond_leash >0 else -(dist_beyond_leash**2 ) 
	dir_to_target = dir_to_target.normalized()
	cam_velocity = -dir_to_target * dist_beyond_leash
	# add in extra Y movement to keep the camera on our desired plane
	var y_mov = global_position.y  - (target_current.global_position.y + follow_offset.y)
	cam_velocity.y -= y_mov
	# Apply 
	global_position += cam_velocity * delta

func _look_old(delta):
	if target_curr != Vector3.ZERO:
		_look_target_lock(delta)
		return
	# transform target to screen space
	var target_screenPos = unproject_position(target_current.global_position)
	#print(target_screenPos)
	var midscreen = get_viewport().size * look_offset_screen_percent
	# Get direction to target
	var target_vector = (global_position-target_current.global_position).normalized()
	var something = global_basis.z
	something.y = 0
	something = something.normalized()
	# Calculate rotation
	var x_rot = (something).signed_angle_to(target_vector -Vector3(0,target_vector.y, 0), Vector3.UP)
	cam_rot_velocity.x = x_rot * 50
	cam_rot_velocity.y = clampf((midscreen.y - target_screenPos.y) * 0.06 , -5, 5) # TODO - Remove magic numbers
	# Apply 
	rotation_degrees.y += cam_rot_velocity.x * (cam_rot_velocity.x**2) * delta
	rotation_degrees.x += cam_rot_velocity.y * (cam_rot_velocity.y**2) * delta
	rotation_degrees.x = clampf(rotation_degrees.x, -60, 80)

func _look(delta):
	if target_curr != Vector3.ZERO:
		_look_target_lock(delta)
		return
	target_curr = target_current.global_position
	look_at(target_curr)
	rotate(basis.x, deg_to_rad(31.5))

func _look_target_lock(_delta):
	look_at(target_curr)
	rotate(basis.x, deg_to_rad(-28.5))

func _look_target_lock_old(delta):
	# transform target to screen space
	var target_screenPos = unproject_position(target_curr)
	var midscreen = get_viewport().size * 0.2
	# Get direction to target
	var target_vector = (global_position-target_curr).normalized()
	var something = global_basis.z
	something.y = 0
	something = something.normalized()
	# Calculate rotation
	var x_rot = (something).signed_angle_to(target_vector -Vector3(0,target_vector.y, 0), Vector3.UP)
	cam_rot_velocity.x = x_rot * 10
	cam_rot_velocity.y = clampf((midscreen.y - target_screenPos.y) * 0.06 , -5, 5) # TODO - Remove magic numbers
	# Apply 
	rotation_degrees.y += cam_rot_velocity.x * (cam_rot_velocity.x**2) * delta
	rotation_degrees.x += cam_rot_velocity.y * (cam_rot_velocity.y**2) * delta
	rotation_degrees.x = clampf(rotation_degrees.x, -60, 80)



func player_look(delta):
	var disLook =  Input.get_vector("p1_look_left", "p1_look_right", "p1_look_dn", "p1_look_up")
	camLookVel += ((global_basis.x * disLook.x) + (global_basis.y * disLook.y)) * delta * camLookAccell
	camLookVel -= camLookVel * (0.9 * delta)
	global_position += camLookVel * delta * camLookSpeed