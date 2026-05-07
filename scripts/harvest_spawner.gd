## Harvest Spawner to spawn harvestable items in semi random bunches.

## Kale the Quick

extends Node3D

## The 3D item that will be spawned at the spawn points on start
@export var harvestable : PackedScene
## The inventory item that will be assigned to the harvestable
## This item cannot be on the harvestable prefab, because it causes a cyclic load error.
@export var item_to_harvest : InventoryItem

@export var spawn_points : Array[Node3D]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_goodies()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func spawn_goodies():
	for spot in spawn_points:
		var n_goodie = harvestable.instantiate()
		#n_goodie.global_transform = spot.global_transform
		spot.add_child(n_goodie)
		n_goodie.item = item_to_harvest