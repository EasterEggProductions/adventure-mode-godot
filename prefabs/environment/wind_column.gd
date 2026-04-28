extends Area3D
class_name WindColumn3D

## Velocity (m/s) applied to actors gliding inside this column.
@export var wind_velocity: Vector3 = Vector3(0, 3, 0)

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	tree_exiting.connect(_on_tree_exiting)

func _on_body_entered(body: Node3D):
	if body is Actor:
		body.wind_columns_inside.append(self)

func _on_body_exited(body: Node3D):
	if body is Actor:
		body.wind_columns_inside.erase(self)

func _on_tree_exiting():
	for actor in Actor.ALL_EVER_MADE:
		if is_instance_valid(actor):
			actor.wind_columns_inside.erase(self)
