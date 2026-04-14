extends Node

## The character who's inventory we will be displaying
@export var inspectingChar : Character

## The region of the screen where we will create item buttons
@export var item_button_spot : GridContainer

var hiddenKiddo : TextureButton

func _ready(): 
	hiddenKiddo = item_button_spot.get_child(0) # grabs the first child, 
	remove_child(hiddenKiddo) # remove the kid to save for later

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
	return nb

func inventory_debug() :
	print("Inventory:")
	for item in inspectingChar.my_inventory :
		print(item.resource_name)
