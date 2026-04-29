extends Node

class_name DresserUpper

@export var actor : Node3D 
@export var skele : Skeleton3D

var things_worn : Dictionary# NOTE Actual nodes created

@export var garments : Array[Garment] # NOTE Resource references
@export var accessories : Array[Accessory]


var material_overlay : Material

signal outfit_changed
signal garment_changed
signal accessory_changed

# Called when the node enters the scene tree for the first time.
func _ready():
	things_worn = {}
	#var oldgar = garments
	#garments = []
	#for garment in oldgar:
	#	garment_equip(garment)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


# SECTION Dress up functions

func garment_equip(gar : Garment):
	if gar in garments:
		return
	var mesh = gar.spawn_garmet()
	skele.add_child(mesh)
	mesh.skeleton = skele.get_path()
	mesh.lod_bias = 10
	things_worn[gar] = mesh
	garments.append(gar)
	if material_overlay:
		mesh.material_overlay = material_overlay
	if is_multiplayer_authority():
		garment_change.rpc(gar.resource_path, true)
	outfit_changed.emit()
	garment_changed.emit()

func garment_unequip(gar : Garment):
	if gar in things_worn.keys():
		var mesh = things_worn[gar]
		mesh.queue_free()
	garments.erase(gar)
	things_worn.erase(gar)
	if is_multiplayer_authority():
		garment_change.rpc(gar.resource_path, false)
	outfit_changed.emit()
	garment_changed.emit()

func garment_tweak(gar : Garment, property_name : String, v : Variant):
	if(gar in things_worn):
		gar.set_garment_property(property_name, v)
	# else not found, NO FEEDBACK	
	outfit_changed.emit()
	garment_changed.emit()

func accessory_equip(acc : Accessory, different_bone=""):
	var bone_follow =  acc.spawn_item()
	skele.add_child(bone_follow)
	if different_bone != "":
		bone_follow.bone_name = different_bone
	else:
		bone_follow.bone_name = acc.bones[0]
	things_worn[acc] = bone_follow #NOTE Maybe not good, child object being the thing and all.
	accessories.append(acc)
	if is_multiplayer_authority():
		accessory_change.rpc(acc.resource_path, true, different_bone)
	outfit_changed.emit()
	accessory_changed.emit()

func accessory_unequip(acc : Accessory, different_bone=""):
	if acc in things_worn.keys():
		var accessory = things_worn[acc]
		if is_instance_valid(accessory):
			accessory.queue_free()
	accessories.erase(acc)
	things_worn.erase(acc)
	if is_multiplayer_authority():
		accessory_change.rpc(acc.resource_path, false, different_bone)
	outfit_changed.emit()
	accessory_changed.emit()

@rpc
func accessory_change(a_path : String, equip : bool, different_bone=""):
	if a_path == "": 
		return
	if equip:
		accessory_equip(load(a_path), different_bone)
	else:
		accessory_unequip(load(a_path), different_bone)

@rpc
func garment_change(g_path : String, equip : bool):
	if g_path == "": 
		return
	if equip:
		garment_equip(load(g_path))
	else:
		garment_unequip(load(g_path))

@rpc
func _rpc_sync_outfit_to(the_fit : PackedStringArray):
	print("%d, %d says to sync that outfit!" % [multiplayer.get_unique_id(), multiplayer.get_remote_sender_id()])
	print(the_fit)
	outfit_load(the_fit)

func sync_outfit_to(peer_id : int):
	# NOTE - short delay to make sure everyone has spawned, this should be improved, perhaps by adding a connected player resource to hold info
	await get_tree().create_timer(3).timeout 
	print(str(multiplayer.get_unique_id()) +  ", Sync that outfit!")
	var the_fit : PackedStringArray = outfit_save()
	_rpc_sync_outfit_to.rpc_id(peer_id, the_fit)

func accessory_item(acc : Accessory):
	# Find item that exists physically, and return it
	
	if acc in things_worn:
		return things_worn[acc]
	else:
		return null

## Returns first accessory on a bone - Currently for getting weapons
## Returns bone follow node
func accessory_on_bone(bone : String):
	for acc in accessories:
		if acc in things_worn.keys() and things_worn[acc].bone_name == bone:
			return things_worn[acc]

func outfit_save() -> PackedStringArray:
	var mes : PackedStringArray = []
	#for item in things_worn:
	#	mes += item.serialize() + "\n"
	for gar in garments:
		mes.append("G|" + gar.resource_path)
	for acc in accessories:
		mes.append("A|" + acc.resource_path)
	return mes
	
func outfit_load(outfit_data : PackedStringArray):
	undress()
	
	for item in outfit_data:
		if item.begins_with("A"):
			accessory_equip(load(item.substr(2)))
		else:
			garment_equip(load(item.substr(2)))
	

func undress():
	var working_array = things_worn.duplicate()
	for item in working_array:
		unequip_item(item)

# SECTION Utility
func conflicting_items(item):
	var bones = item.bones # the spots this item occupies
	var returnable = []
	for thing in things_worn:
		for bone in bones:
			if bone in thing.bones && thing not in returnable:
				returnable.append(thing)
	return returnable

func conflict_check(item):
	var bones = item.bones # the spots this item occupies
	for thing in things_worn: # Fuck me, really do jesis
		for bone in bones:
			if bone in thing.bones:
				return true
	return false


		
func is_item_equipped(thing):
	return thing in things_worn

func unequip_item(item_removed):
	if item_removed is Accessory:
		accessory_unequip(item_removed)
	else:
		garment_unequip(item_removed)


func set_material_overlay(overlay : Material) -> void:
	material_overlay = overlay
	for gar in garments:
		var mesh : MeshInstance3D =  things_worn[gar]
		mesh.material_overlay = material_overlay
	## TODO - Accesories

func clear_material_overlay() -> void: 
	set_material_overlay(null)