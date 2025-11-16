@tool
extends EditorPlugin

# file that loads the plugin

const MyCustomGizmoPlugin = preload("res://addons/dungeon_tools_gizmos/custom_gizmo_plugin.gd")
var gizmo_plugin = MyCustomGizmoPlugin.new()

func _enter_tree():
	add_node_3d_gizmo_plugin(gizmo_plugin)

func _exit_tree():
	remove_node_3d_gizmo_plugin(gizmo_plugin)
