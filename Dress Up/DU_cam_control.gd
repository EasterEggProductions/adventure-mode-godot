extends Camera3D

@export var target_character : Node3D
var sensitivity : float = 5
@export var camera_height_bounds : Vector2 = Vector2(1, 5)
@export var zoom_speed : float = 15
var current_camera_height : float = 1.5

func _ready():
	move_camera_vertical(0)
	rotate_character(0)
	zoom_camera(0)
	pass

func _process(delta):
	# Rotate character with left and right mouse movement
	if Input.is_key_pressed(KEY_LEFT):
		rotate_character(delta * sensitivity)
	elif Input.is_key_pressed(KEY_RIGHT):
		rotate_character(-delta * sensitivity)

	# Move camera up and down with up and down mouse movement
	if Input.is_key_pressed(KEY_UP):
		move_camera_vertical(delta)
	elif Input.is_key_pressed(KEY_DOWN):
		move_camera_vertical(-delta)

	# Zoom in and out with mouse wheel

	if Input.is_key_pressed(KEY_PAGEUP):
		zoom_camera(delta)
	elif Input.is_key_pressed(KEY_PAGEDOWN):
		zoom_camera(-delta)

func rotate_character(delta_angle):
	target_character.rotate_y(delta_angle)

func move_camera_vertical(delta):
	current_camera_height = clamp(current_camera_height + delta * sensitivity, camera_height_bounds.x, camera_height_bounds.y)
	global_transform.origin.y = current_camera_height

func zoom_camera(zoom_input):
	var n_fov = clamp(fov - (zoom_input * zoom_speed), 10, 70)
	print(n_fov)
	fov = n_fov
#	global_transform.origin.z = clamp(current_camera_height - zoom_input * zoom_speed, camera_height_bounds.x, camera_height_bounds.y)
