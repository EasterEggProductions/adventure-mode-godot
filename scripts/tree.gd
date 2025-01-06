extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$tree_base.rotate_y(randi() % 360)
	$tree_second.rotate_y(randi() % 360)
	$tree_top.rotate_y(randi() % 360)
	pass # Replace with function body.
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
