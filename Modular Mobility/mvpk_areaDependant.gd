extends MovementPackage

class_name mvpk_area_dep

@export var area_type = "water"
#@export_multiline var movement_extra_expression : String

var LDT = 0.1 # last delta time, some error or something, idk
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func transfer_situation_check(thrall : Actor) -> bool:
	return shape_check(thrall)

func release_situation_check(thrall : Actor) -> bool:
	return !shape_check(thrall)

func shape_check(thrall : Actor) -> bool:
	var shape = thrall.get_node("water_cast") #NOTE Stand in situation gantry
	for x in range(shape.get_collision_count()):
		if is_instance_valid(shape.get_collider(x)) and  shape.get_collider(x).name == area_type:
			return true
	return false


func move_thrall(thrall : Actor, delta : float):
	# Get the motion delta.
	thrall.velocity = ((thrall.animation_tree.get_root_motion_rotation_accumulator().inverse() * thrall.get_quaternion()) * thrall.animation_tree.get_root_motion_position() / delta) * 2

	# NOTE - Not specifically 'area dependant movement'
	# NOTE - This is specific to swimming
	var shape = thrall.get_node("water_cast") #NOTE Stand in situation gantry
	var bouyancy = 0
	for x in range(shape.get_collision_count()):
		#print(shape.get_collider(x).name)
		if shape.get_collider(x).name == area_type:
			#var water_zone : Area3D = shape.get_collider(x)
			# TODO - get top of water area
			var surface_height = -0.419204 # hard coded water height from blender geometry
			bouyancy = shape.global_position.y - surface_height + 0.5
			thrall.velocity.y = bouyancy# + 0.05
			thrall.velocity.y = clampf(thrall.velocity.y, 0.5, -0.5)


	thrall.quaternion = thrall.quaternion * ((thrall.animation_tree.get_root_motion_rotation() / delta) * 10)
	thrall.combat_mode = false # FIXME - Better technique needed to prevent trying to enter combat states from swimming










