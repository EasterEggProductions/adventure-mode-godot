extends InventoryItem
class_name InventoryArmament

@export var held_item : Accessory # TODO - Name better
@export var moveset : MovementPackage

@export var dvalues : Dictionary[String, int] = {
	"physical":3,
	"poise":1,
	"magic":0,
	"poison":0,
	"lacerating":0
}