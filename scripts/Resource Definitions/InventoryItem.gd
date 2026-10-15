extends Resource
class_name InventoryItem

## Display of this item in inventory, and descriptions
@export var icon : Texture2D 
@export_multiline var description : String

## Item instanced on drop and given reference to this resource for pickup
@export var drop_item : PackedScene

## Options for the item's inventory behaviour
@export_group("Flags")
## Items form a stack in the inventory, like potions, or do not, like duplicates of the same weapon
@export var stackable = true
## Identical instances can stack
@export var fungible = false 
## Use a float for amount? For things like water. NOTE - perhaps a fixed decimal amount is fine for a game, avoids floating point errors
@export var volumetric = false 

@export_group("Extra Data")
@export var extra_resources : Dictionary[String, Resource]

## The action to use the item if any, string for action_q
@export var use_action = ""

## If this item has been tweaked or modified, for example to keep
## an amount value, weapon damage, durability, etc, it will use 
## this reference for checking if things are the same item, or
## reverting back to a base state. DO NOT USE THIS unless you
## are absolutely sure what you are doing. 
@export var base_item : InventoryItem