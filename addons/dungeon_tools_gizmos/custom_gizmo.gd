extends EditorNode3DGizmo

const Y_OFFSET = Vector3(0, 0.2, 0)
var spawnpoint_meshes = {
	Spawnpoint3D.Subtype.DEFAULT: load("res://addons/dungeon_tools_gizmos/meshes/spawn_default.obj"),
	Spawnpoint3D.Subtype.MULTIPLAYER: load("res://addons/dungeon_tools_gizmos/meshes/spawn_multiplayer.obj"),
	Spawnpoint3D.Subtype.WALK_IN: load("res://addons/dungeon_tools_gizmos/meshes/spawn_walk_in.obj"),
}

func _redraw():
	clear()
	var plugin = get_plugin()
	var node = get_node_3d()
	var button_node: DungeonButton = node if node is DungeonButton else null
	var spawnpoint_node: Spawnpoint3D = node if node is Spawnpoint3D else null
	
	## Draw gizmo for dungeon buttons
	if button_node:
		# don't draw anything if the node isnt selected
		if not EditorInterface.get_selection().get_selected_nodes().has(button_node):
			return
		
		# if the button isn't connected, don't draw
		if button_node == null or button_node.connected == null:
			return
			
		var mat = plugin.get_material("button_line")
		mat.albedo_color = Color(1.0, 1.0, 0.4)
		
		var lines: PackedVector3Array
		lines.append(Vector3(0, 0, 0))
		lines.append(button_node.to_local(button_node.connected.global_position + Y_OFFSET*4) + Y_OFFSET)
		add_lines(lines, mat)
	
	## Draw gizmo for spawnpoints
	if spawnpoint_node:
		var mat = plugin.get_material("spawnpoint")
		mat.albedo_color = Color(1.0, 0.3, 0.2)
		add_mesh(spawnpoint_meshes[spawnpoint_node.subtype], mat)
