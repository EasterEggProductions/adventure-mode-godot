extends Node


## The character who's equipment we will be managing
@export var inspectingChar : Character
## The region of the screen where we will create item buttons
@export var equip_button_spot : GridContainer

@export var hover_tex : Texture2D
@export var empty_slot : Texture2D

@export var flavor_textbox : RichTextLabel

@export var image_box : TextureRect


func _ready(): 
	if is_instance_valid(MgrPlayerSocket.get_player_one()):
		inspectingChar = MgrPlayerSocket.get_player_one().thrall.character

	kill_all_children()
	make_item_buttons()


func kill_all_children() :
	# Remove the children
	for child in equip_button_spot.get_children():
		child.queue_free()
		equip_button_spot.remove_child(child)

func make_item_buttons() :
	if len(inspectingChar.my_inventory) == 0:
		return
	var separator = HSeparator.new()
	separator.custom_minimum_size = Vector2(128,32)
	# make new, nicer, kids
	var r_label = Label.new()
	r_label.text = "Right hand tools"
	equip_button_spot.add_child(r_label)
	equip_button_spot.add_child(separator.duplicate())
	equip_button_spot.add_child(separator.duplicate())
	equip_button_spot.add_child(separator.duplicate())
	equip_button_spot.add_child(separator.duplicate())
	for x in range(inspectingChar.hand_r_size):
		var new_button = make_item_button(inspectingChar.hand_right_slots[x], x, inspectingChar.hand_right_slots)
		equip_button_spot.add_child(new_button)
	# manual pad for now 
	equip_button_spot.add_child(separator.duplicate())
	equip_button_spot.add_child(separator.duplicate())
	

	var l_label = Label.new()
	l_label.text = "Left hand tools"
	equip_button_spot.add_child(l_label)
	equip_button_spot.add_child(separator.duplicate())
	equip_button_spot.add_child(separator.duplicate())
	equip_button_spot.add_child(separator.duplicate())
	equip_button_spot.add_child(separator.duplicate())
	for x in range(inspectingChar.hand_l_size):
		var new_button = make_item_button(inspectingChar.hand_left_slots[x], x, inspectingChar.hand_left_slots)
		equip_button_spot.add_child(new_button)
	# manual pad for now 
	equip_button_spot.add_child(separator.duplicate())
	equip_button_spot.add_child(separator.duplicate())
	

	var s_label = Label.new()
	s_label.text = "Spells"
	equip_button_spot.add_child(s_label)
	equip_button_spot.add_child(separator.duplicate())
	equip_button_spot.add_child(separator.duplicate())
	equip_button_spot.add_child(separator.duplicate())
	equip_button_spot.add_child(separator.duplicate())
	for x in range(inspectingChar.spells_size):
		var new_button = make_item_button(inspectingChar.spells_slots[x], x, inspectingChar.spells_slots)
		equip_button_spot.add_child(new_button)
	# manual pad for now 
	equip_button_spot.add_child(separator.duplicate())
	equip_button_spot.add_child(separator.duplicate())
	
	var b_label = Label.new()
	b_label.text = "Belt Items"
	equip_button_spot.add_child(b_label)
	equip_button_spot.add_child(separator.duplicate())
	equip_button_spot.add_child(separator.duplicate())
	equip_button_spot.add_child(separator.duplicate())
	equip_button_spot.add_child(separator.duplicate())
	for x in range(inspectingChar.belt_size):
		var new_button = make_item_button(inspectingChar.belt_items[x], x, inspectingChar.belt_items)
		equip_button_spot.add_child(new_button)
	# manual pad for now 
	equip_button_spot.add_child(separator.duplicate())

	#var index = 0
	#for item in inspectingChar.my_inventory :
	#	var new_button = make_item_button(item, index)
	#	equip_button_spot.add_child(new_button)
	#	index += 1
		

	var bb : TextureButton = equip_button_spot.get_child(5) 
	bb.grab_focus.call_deferred()

func make_item_button(item : InventoryItem, index : int, slots : Array) -> TextureButton:
	var nb = TextureButton.new()
	if item != null:
		nb.texture_normal = item.icon
	else:
		nb.texture_normal = empty_slot
	nb.texture_focused = hover_tex
	nb.stretch_mode = TextureButton.STRETCH_SCALE
	nb.custom_minimum_size = Vector2(128, 128)
	nb.custom_maximum_size = Vector2(128, 128)
	nb.connect("pressed", button_press.bind(slots).bind(index).bind(item).bind(nb))
	nb.connect("focus_entered", button_focus.bind(item))
	return nb

func button_press(button : TextureButton, item : InventoryItem, item_index : int, slots : Array):
	inspectingChar.unequip_item(slots, item)
	button.texture_normal = empty_slot
	quick_picker(slots, item_index)

func button_focus(item : InventoryItem) -> void:
	print(item)
	if item == null:
		flavor_textbox.text = "[b][center]Empty Slot[/center][/b]\n"
		image_box.texture = empty_slot
		return
	flavor_textbox.text = "[b][center]" + item.resource_name + "[/center][/b]\n" + item.description
	image_box.texture = item.icon

func inventory_debug() :
	print("Inventory:")
	for item in inspectingChar.my_inventory :
		print(item.resource_name)



# For user picking an item
func quick_picker(slots : Array, index : int): 
	var layout = equip_button_spot.duplicate()
	for child in layout.get_children():
		child.queue_free()
	equip_button_spot.visible = false 
	equip_button_spot.get_parent().add_child(layout)
	layout.name = "item_pick"
	# item pick specific buttons 
	var focus_item : TextureButton
	var buttons : Array[TextureButton]
	for item in inspectingChar.my_inventory:
		if item == null:
			continue
		var nb = TextureButton.new()
		nb.texture_normal = item.icon
		nb.texture_focused = hover_tex
		nb.stretch_mode = TextureButton.STRETCH_SCALE
		nb.custom_minimum_size = Vector2(128, 128)
		nb.custom_maximum_size = Vector2(128, 128)
		nb.connect("pressed", qp_button_press.bind(index).bind(slots).bind(item))
		nb.connect("focus_entered", button_focus.bind(item))
		#nb.focus_mode = Control.FOCUS_ALL
		buttons.append(nb)
		layout.add_child(nb)
		if item == slots[index]:
			focus_item = nb

	if focus_item == null:
		focus_item = buttons[0]
	await get_tree().create_timer(1).timeout
	focus_item.grab_focus()
		

# NOTE - Messy 
var picked_item : InventoryItem
func qp_button_press(item : InventoryItem, slots : Array, index : int):
	inspectingChar.equip_item(slots, index, item)
	flavor_textbox.text = ""
	image_box.texture = empty_slot
	equip_button_spot.get_parent().find_child("item_pick", false, false).queue_free()
	equip_button_spot.visible = true