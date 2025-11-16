extends Node3D
class_name DungeonRoom

@export var enemy_group: String = "enemies"
@export var room_doors: Array[DungeonDoor] = []

var enemies = []

func _ready() -> void:
	for node in get_children():
		if node.is_in_group(enemy_group):
			enemies.append(node)
			node.connect("actor_killed", Callable(self.on_child_actor_killed))
			_print_debug("enemy " + node.name + " has been registered")
			
	#for door_name in enabled_doors:
		#if door_locs.has_node(door_name):
			#var door_location: Node3D = door_locs.get_node(door_name)
			#var disabled_door: Node3D = disabled_door_scene.instantiate()
			#disabled_door.position = door_location.position
			#disabled_door.scale = Vector3(2,2,2) # NOTE: temp, re-export in blender
			#add_child(disabled_door)
		#else:
			#push_warning("[Room] Door \"" + door_name + "\" doesn't exist.")

func _physics_process(delta: float) -> void:
	pass

func on_child_actor_killed(actor_node: Actor):
	if actor_node in enemies:
		_print_debug("\"" + actor_node.name + "\" killed")
		enemies.erase(actor_node)
	if enemies.is_empty():
		open_doors()
		_print_debug("All room enemies defeated.")

func open_doors():
	for door: DungeonDoor in room_doors:
		if door.controlled_by_room:
			door.open_door()

func _print_debug(msg: String):
	print("[" + self.name + "] " + msg)
