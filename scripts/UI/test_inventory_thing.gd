extends Node

## The character who's inventory we will be displaying
@export var inspectingChar : Character

## The region of the screen where we will create item buttons
@export var item_button_spot : GridContainer


func _ready(): 
	if is_instance_valid(MgrPlayerSocket.get_player_one()):
		inspectingChar = MgrPlayerSocket.get_player_one().thrall.character

	kill_all_children()
	make_item_buttons()

		
func _process(_delta):
	# Note, is true while key held down
	if Input.is_key_pressed(KEY_P):
		kill_all_children()
		make_item_buttons()

func kill_all_children() :
	# Remove the children
	for child in item_button_spot.get_children():
		child.queue_free()

func make_item_buttons() :
	# make new, nicer, kids
	for item in inspectingChar.my_inventory :
		var new_button = make_item_button(item)
		item_button_spot.add_child(new_button)

	item_button_spot.get_child(1).grab_focus()

func make_item_button(item : InventoryItem) -> TextureButton:
	var nb = TextureButton.new()
	nb.texture_normal = item.icon
	nb.stretch_mode = TextureButton.STRETCH_SCALE
	nb.custom_minimum_size = Vector2(128,128)
	nb.connect("pressed", button_press.bind(item))
	return nb

func button_press(item : InventoryItem):
	print("Item button: " + item.resource_name)

	# To drop the item, 
	# Create the item's drop item, and place it in 3D space
	var drop : Node3D
	if item.drop_item != null:
		drop = item.drop_item.instantiate() 
		drop.item = item
	else:
		var tempDroppy : MeshInstance3D = MeshInstance3D.new()
		var nMesh : SphereMesh = SphereMesh.new()
		nMesh.radius = 0.5
		nMesh.height = 1
		tempDroppy.mesh = nMesh
		drop = tempDroppy
	if is_instance_valid(MgrPlayerSocket.get_player_one()):
		drop.transform = MgrPlayerSocket.get_player_one().thrall.transform
	get_tree().current_scene.add_child(drop)
	# remove this item from the characters inventory
	inspectingChar.my_inventory.remove_at(inspectingChar.my_inventory.find(item))
	# delete the associated button, OR just re make all buttons for now
	kill_all_children()
	make_item_buttons()

func inventory_debug() :
	print("Inventory:")
	for item in inspectingChar.my_inventory :
		print(item.resource_name)
