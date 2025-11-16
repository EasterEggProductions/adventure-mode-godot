extends EditorNode3DGizmoPlugin

const PLUGIN_PATH = "res://addons/dungeon_tools_gizmos/"
const CustomGizmo = preload(PLUGIN_PATH + "custom_gizmo.gd")

func _init():
	# for some reason the material doesn't have the correct color set in init()
	create_material("main", Color(1, 0, 0))
	create_handle_material("handles")

func _create_gizmo(node):
	# Only buttons will show where they're connected for now
	if node is DungeonButton:
		return CustomGizmo.new()
	else:
		return null

func _get_gizmo_name() -> String:
	return "hell yeah a gizmo!"
