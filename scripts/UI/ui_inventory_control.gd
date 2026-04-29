extends Node

## The character who's inventory we will be displaying
@export var inspectingChar : Character

## The region of the screen where we will create item buttons
@export var item_button_spot : GridContainer

@export var hover_tex : Texture2D

@export var flavor_textbox : RichTextLabel

@export var image_box : TextureRect

func _ready(): 
	if is_instance_valid(MgrPlayerSocket.get_player_one()):
		inspectingChar = MgrPlayerSocket.get_player_one().thrall.character

	kill_all_children()
	make_item_buttons()


func kill_all_children() :
	# Remove the children
	for child in item_button_spot.get_children():
		child.queue_free()
		item_button_spot.remove_child(child)

func make_item_buttons() :
	if len(inspectingChar.my_inventory) == 0:
		return
	# make new, nicer, kids
	var index = 0
	for item in inspectingChar.my_inventory :
		var new_button = make_item_button(item, index)
		item_button_spot.add_child(new_button)
		index += 1
		

	var bb : TextureButton = item_button_spot.get_child(0) 
	bb.grab_focus.call_deferred()

func make_item_button(item : InventoryItem, index : int) -> TextureButton:
	var nb = TextureButton.new()
	nb.texture_normal = item.icon
	nb.texture_focused = hover_tex
	nb.stretch_mode = TextureButton.STRETCH_SCALE
	nb.custom_minimum_size = Vector2(128,128)
	nb.connect("pressed", button_press.bind(index).bind(item))
	nb.connect("focus_entered", button_focus.bind(item))
	return nb

func button_press(item : InventoryItem, index : int):
	print("Item button: " + item.resource_name)

	# To drop the item, 
	# Create the item's drop item, and place it in 3D space
	var drop : Node3D
	if item.drop_item != null:
		drop = item.drop_item.instantiate() 
		drop.item = item
	else:
		drop = Harvestable.new()
		# Mesh 
		var mesh_render : MeshInstance3D = MeshInstance3D.new()
		var nMesh : SphereMesh = SphereMesh.new()
		nMesh.radius = 0.1
		nMesh.height = 0.2
		mesh_render.mesh = nMesh
		drop.add_child(mesh_render)
		# Collision 
		var col_shape : CollisionShape3D = CollisionShape3D.new()
		var col_sphere : SphereShape3D = SphereShape3D.new()
		col_sphere.radius = 1
		col_shape.shape = col_sphere
		drop.add_child(col_shape)
		
		drop.item = item
		drop.harvest_name = item.resource_name
	if is_instance_valid(MgrPlayerSocket.get_player_one()):
		drop.transform = MgrPlayerSocket.get_player_one().thrall.transform
		drop.position = drop.position + Vector3(0,0.1,0) + (MgrPlayerSocket.get_player_one().thrall.global_basis.z * 0.5)
	get_tree().current_scene.add_child(drop)
	# remove this item from the characters inventory
	inspectingChar.my_inventory.remove_at(inspectingChar.my_inventory.find(item))
	# delete the associated button, OR just re make all buttons for now
	kill_all_children()
	make_item_buttons()
	if item_button_spot.get_child_count() > 0:
		if index < item_button_spot.get_child_count():
			item_button_spot.get_child(index).grab_focus.call_deferred()
		else:
			item_button_spot.get_child(-1).grab_focus.call_deferred()
			
	flavor_textbox.text = ""
	image_box.texture = null

func button_focus(item : InventoryItem) -> void:
	flavor_textbox.text = "[b][center]" + item.resource_name + "[/center][/b]\n\n" + item.description
	image_box.texture = item.icon

func inventory_debug() :
	print("Inventory:")
	for item in inspectingChar.my_inventory :
		print(item.resource_name)
