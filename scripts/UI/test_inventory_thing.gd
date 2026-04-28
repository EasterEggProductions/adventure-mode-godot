extends Node

## The character who's inventory we will be displaying
@export var inspectingChar : Character

## The region of the screen where we will create item buttons
@export var item_button_spot : GridContainer

@export var hover_tex : Texture2D

@export var flavor_textbox : RichTextLabel

@export var image_box : TextureRect

# A dictionary to test out the item flavor text display
# Not the most optimal solution, but it works for the time being
var flavor_texts := {
	"icon_commonFruit.png": 
		["Common Fruit", "The common fruit of awesomeness!!!"],
	"icon_coin.png" : 
		["Coin","The coin of prosperity!!!"],
	"ico_sword_debug.png" : 
		["Sword Debug", "The sword debug of debugginess!!!"],
	"ico_greatsword_debug.png": 
		["Great Sword Debug", "The great sword of greatness!!!"],
	"ico_sword_of_godot.png": 
		["Sword of Godot", "The sword of godot of awesomeness!!!"],
	"ico_spear_debug.png": 
		["Spear Debug", "The sword debug of debugginess!!!"],
	"icon_axe_questions.png": 
		["Axe", "The axe of questions!!!"]
}

func _ready(): 
	if is_instance_valid(MgrPlayerSocket.get_player_one()):
		inspectingChar = MgrPlayerSocket.get_player_one().thrall.character
		flavor_textbox.text = "This is a test."

	kill_all_children()
	make_item_buttons()

		
func _process(_delta):
	# Runs every time a frame is drawn
	
	# Go grab the thing that is currently focused
	var focused = get_viewport().gui_get_focus_owner()

	# Display the image, name, and flavor text of the focused item
	if focused is TextureButton:
		var tex = focused.texture_normal
		if tex:
			var img_name = tex.resource_path.replace("res://art/textures/icons/", "")
			flavor_textbox.text = "[b]" + flavor_texts.get(img_name)[0] + "[/b]\n\n" + flavor_texts.get(img_name)[1]
			image_box.texture = tex
	# Display this text if the back button is focused
	elif focused is Button :
		flavor_textbox.text = "Go back to pause menu."
		image_box.texture = null
	# Display a message about empty inventory
	else:
		flavor_textbox.text = "Your inventory is empty. :("
		image_box.texture = null

	# Note, is true while key held down
	if Input.is_key_pressed(KEY_P):
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
		drop.position = drop.position + Vector3(0,0.1,0)
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

func inventory_debug() :
	print("Inventory:")
	for item in inspectingChar.my_inventory :
		print(item.resource_name)
