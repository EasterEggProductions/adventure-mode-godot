extends MovementPackage

class_name mvpk_climb

var last_col_result

func transfer_situation_check(thrall : Actor) -> bool:
	# Climb when 1- airborne 2- desired movement toward climbable (any wall for now) (forward only for now)
	if thrall.is_on_floor():
		return false
	
	var space_state = thrall.get_world_3d().direct_space_state
	var origin = thrall.global_position + Vector3.UP
	var end = origin + thrall.global_basis.z
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	#query.collide_with_areas = true
	last_col_result = space_state.intersect_ray(query)
	#print(result)
	if "collider" in last_col_result.keys() and thrall.desired_move.length() > 1.2:
		return true

	#printerr("ERROR - Not implimented")
	return false # We are abstract kinda, always not be here

func release_situation_check(thrall : Actor) -> bool:	
	if Input.is_action_just_pressed("p1_crouch"):
		print("first exti")
		thrall.look_at(thrall.global_position - (thrall.global_basis.z * Vector3(1,0,1)))
		return true
	if thrall.animation_tree.get("parameters/climb/conditions/ledge_vault_exit")  == true:
		# await end of anim
		#if thrall.animation_tree.finish
		return false
	# Phys ray
	var space_state = thrall.get_world_3d().direct_space_state
	var origin = thrall.global_position + Vector3.UP
	var end = origin + (thrall.global_basis.z * 1.5)
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	#query.collide_with_areas = true
	last_col_result = space_state.intersect_ray(query)

	# NOTE - fix for orientation changes during climbing
	#print(result)
	if "collider" in last_col_result.keys():
		return false
	print("final exit")
	thrall.look_at(thrall.global_position - (thrall.global_basis.z * Vector3(1,0,1)))
	return true

func move_thrall(thrall : Actor, delta : float):	
	# Get the motion delta.
	thrall.velocity = ((thrall.animation_tree.get_root_motion_rotation_accumulator().inverse() * thrall.get_quaternion()) * thrall.animation_tree.get_root_motion_position() / delta)# * 2

	# Phys ray
	#var space_state = thrall.get_world_3d().direct_space_state
	#var origin = thrall.global_position + Vector3.UP
	#var end = origin + thrall.global_basis.z
	#var query = PhysicsRayQueryParameters3D.create(origin, end)
	#query.collide_with_areas = true
	#last_col_result = space_state.intersect_ray(query)
	#print(result)
	#if "collider" not in last_col_result.keys() :
	#	return

	if "normal" in last_col_result.keys():
		thrall.look_at(thrall.global_position + last_col_result["normal"])
	#print(last_col_result["normal"])
	
	thrall.quaternion = thrall.quaternion * ((thrall.animation_tree.get_root_motion_rotation() / delta) * 10)

	thrall.move_and_slide()
	ledge_vault_check(thrall)


func ledge_vault_check(thrall : Actor):
	
	# Phys ray
	var space_state = thrall.get_world_3d().direct_space_state
	var end = thrall.global_position + Vector3(0,0,-0.55)
	var origin = end + Vector3(0,2.1,0)
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	#query.collide_with_areas = true
	#print(str(origin) + " ~ " + str(end))
	var col_result = space_state.intersect_ray(query)
	print("collider" in col_result.keys())
	if "collider" in col_result.keys():
		# If we do, do exit
		thrall.animation_tree.set("parameters/climb/conditions/ledge_vault_exit", true) 
	else:
		thrall.animation_tree.set("parameters/climb/conditions/ledge_vault_exit", false) 