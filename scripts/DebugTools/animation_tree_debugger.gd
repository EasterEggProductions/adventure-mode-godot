extends AnimationTree

@export_subgroup("Buttons")
@export var tree = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# aw shit, here we go again
	if tree:
		do_tree()

func do_tree():
	tree = false
	var message = "" # recursive_node_debug(tree_root, "")
	var props = get_property_list()
	for prop in props:
		if "playback" in prop["name"]:
			message += "\n" + prop["name"]
			message += " " + str(get(prop["name"]).is_playing())
			message += " " + str(get(prop["name"]).get_current_node())
			if "0/WalkSprint" in prop["name"]:
				get(prop["name"]).travel("Start")
	#print(get("parameters/playback"))
	print(message)

func recursive_node_debug(node, level) -> String:
	if is_instance_valid(node) == false:
		return ""
	var message = ""
	var next_level = level + "-"
	var props = node.get_property_list()
	for prop in props:
		if prop["class_name"] == "AnimationNode":
			message +=  "\n" + level + prop["name"]
			message += recursive_node_debug(node.get(prop["name"]), next_level)
		elif "playback" in prop["name"]:
			message +=  "\n!!" + level + prop["name"]
	return message