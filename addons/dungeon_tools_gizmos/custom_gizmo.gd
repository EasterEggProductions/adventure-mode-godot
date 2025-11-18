extends EditorNode3DGizmo

const Y_OFFSET = Vector3(0, 0.2, 0)

func _redraw():
	clear()
	var button_node:DungeonButton = get_node_3d()
	var plugin = get_plugin()
	
	# if the button isn't connected, don't draw
	if button_node == null or button_node.connected == null:
		return
	
	# don't draw anything if the node isnt selected
	if not EditorInterface.get_selection().get_selected_nodes().has(button_node):
		return
	
	var mat = plugin.get_material("main")
	mat.albedo_color = Color(1.0, 1.0, 0.4)
	
	var lines: PackedVector3Array
	lines.append(Vector3(0, 0, 0))
	lines.append(button_node.to_local(button_node.connected.global_position + Y_OFFSET*4) + Y_OFFSET)
	add_lines(lines, mat)
