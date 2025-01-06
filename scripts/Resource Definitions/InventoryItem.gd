extends Resource
class_name InventoryItem

## Display of this item in inventory
@export var icon : Texture2D 

## Item instanced on drop and given reference to this resource for pickup
@export var drop_item : PackedScene

## Options for the item's inventory behaviour
@export_group("Flags")
@export var stackable = true
@export var fungible = false
@export var volumetric = false 