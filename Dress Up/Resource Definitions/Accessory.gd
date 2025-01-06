extends Resource
class_name Accessory
# This takes a whole scene and instances it on a character.
# Uses BoneAttachment3D to be in line with how godot works
# Potentially heavier than garmet, 
# For things like swords, shields, etc
var name
# SECTION Visuals of garmet
@export var accessory : PackedScene
# SECTION OTHER DATA
@export var offset : Transform3D
@export var tags : Array[String]
@export var bones : Array[String]

func spawn_item() -> BoneAttachment3D:
	var attachment = BoneAttachment3D.new()
	var new_accessory = accessory.instantiate()
	attachment.add_child(new_accessory)
	new_accessory.transform = offset
	attachment.name = "DressUpAccessory:" + resource_name
	return attachment

func serialize() -> String:
	return "ACCESSORY:" + name + ", tags=" + str(tags) + ", bones=" + str(bones)