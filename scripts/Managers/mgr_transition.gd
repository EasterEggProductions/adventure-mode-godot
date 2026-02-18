extends CanvasLayer

var transitioning = false
var current_load_target = ""

var target_spawn_point : String
var current_level : PackedScene

func change_scene_to_pack(target: PackedScene):	
	print(target)
	MgrPlayerSocket.get_player_one().thrall = null
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
	current_level = target
	$AnimationPlayer.play_backwards("transition")
	#MgrPlayerSocket.spawn_player()
	await $AnimationPlayer.animation_finished
	if target_spawn_point != "":
		get_tree().current_scene.level_start()


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

func level_transition(scene : String, spawn_point : String):
	var new_level = load(scene)
	if new_level == null:
		printerr("Failed to load scene at " + scene)
		return
	current_level = new_level
	print("Going to level %s at entry %s" % [scene, spawn_point] )
	target_spawn_point = spawn_point
	MgrMultiplayer.inform_of_level_change(new_level.resource_path)
	change_scene_to_pack(current_level)