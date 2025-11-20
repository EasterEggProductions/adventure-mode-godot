extends CanvasLayer

var transitioning = false
var current_load_target = ""

func change_scene_to_file(target: String) -> void:
	current_load_target = target
	print(target)
	if transitioning:
		return 
	transitioning = true
	$AnimationPlayer.play("transition")
	#MgrMultiplayerS.map_loadUpdate("loading", current_load_target)
	await $AnimationPlayer.animation_finished
	get_tree().paused = true
	#_extra_cleanup()
	get_tree().change_scene_to_file(current_load_target)
	#MgrMultiplayerS.map_loadUpdate("ready", current_load_target)
	#await MgrMultiplayerS.party_ready
	print("resume")
	transitioning = false
	get_tree().paused = false
	$AnimationPlayer.play_backwards("transition")

func change_scene_to_pack(target: PackedScene):	
	print(target)
	if target == null or is_instance_valid(target) == false:
		# Default to returning to the main scene
		current_load_target = ProjectSettings.get("application/run/main_scene")
		target = load(current_load_target)
	else:
		current_load_target = str(target)
	print(target)
	if transitioning:
		return 
	transitioning = true
	$AnimationPlayer.play("transition")
	#MgrMultiplayerS.map_loadUpdate("loading", current_load_target)
	await $AnimationPlayer.animation_finished
	get_tree().paused = true
	#_extra_cleanup()
	get_tree().change_scene_to_packed(target)
	#MgrMultiplayerS.map_loadUpdate("ready", current_load_target)
	#await MgrMultiplayerS.party_ready
	print("resume")
	transitioning = false
	get_tree().paused = false
	$AnimationPlayer.play_backwards("transition")

func start_transition(target: String):	
	print("start trans")
	current_load_target = target
	#MgrMultiplayerS.map_loadUpdate("loading", target) 
	$AnimationPlayer.play("transition")
	await $AnimationPlayer.animation_finished
	get_tree().paused = true
	get_tree().change_scene_to_file(target)
	#if MgrMultiplayerS.online:
	#	await get_tree().create_timer(3).timeout
	#	MgrMultiplayerS.map_loadUpdate("ready", target)
	#else:
	#	finish_transition()

func finish_transition():
	print("resume")
	get_tree().paused = false
	$AnimationPlayer.play_backwards("transition")

#func _extra_cleanup():
#	if MgrPlayer.ship != null:
#		MgrPlayer.ship.throttle = 0.0

func you_died():
	# play game over sound
	#FAM.play_effect("game_over")
	# fade out screen
	var t =  get_tree().create_tween()
	t.set_parallel(true)
	t.set_trans(Tween.TRANS_BACK)
	t.set_ease(Tween.EASE_OUT)
	t.tween_property($ColorRect, "modulate", Color.BLACK, 6.0)
	# fade in text
	t.tween_property($DUST, "visible_characters", 4, 6.0)
	# fade in reload last save button
	$Buttons.visible = true
	var b =  get_tree().create_tween()
	b.set_trans(Tween.TRANS_BACK)
	b.set_ease(Tween.EASE_OUT)
	b.tween_property($Buttons, "modulate", Color.TRANSPARENT, 4.5)
	b.tween_property($Buttons, "modulate", Color.WHITE, 0.5)

func reload_last_save():
	$DUST.visible_characters = 0
	$Buttons.visible = false
	$Buttons.modulate = Color.TRANSPARENT
	
#	#var savegame = "user://save.tres"
#	# Make sure save folder is here
#	var dir = DirAccess.open("user://")
#	if dir.dir_exists("Saves") == false:
#		dir.make_dir("Saves")
#	dir.change_dir("Saves")
#	print(dir)
#	if dir:
#		dir.list_dir_begin()
#		var file_name = dir.get_next()
#		while file_name != "":
#			if !dir.current_is_dir():
#				#Making button
#				var arr = "" + file_name
#				#if MgrPlayer.char_data.name in arr:
#				#	MgrPoi.uni_load(arr)
#					break
#			file_name = dir.get_next()
#	else:
#		print("An error occurred when trying to access the path.")

func fade_to_quit():
	$AnimationPlayer.play("transition")
	await $AnimationPlayer.animation_finished
	await get_tree().create_timer(0.25).timeout
	get_tree().quit()