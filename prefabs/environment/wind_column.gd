extends DungeonObject
class_name WindColumn3D

## Velocity (m/s) applied to actors gliding inside this column.
@export var wind_velocity: Vector3 = Vector3(0, 3, 0)
@export var enabled: bool = false

@onready var _wind_area = $Area3D
@onready var _particles = $GPUParticles3D

func _ready():
	_wind_area.body_entered.connect(_on_body_entered)
	_wind_area.body_exited.connect(_on_body_exited)
	_wind_area.tree_exiting.connect(_on_tree_exiting)
	if enabled:
		_particles.emitting = true

func _on_body_entered(body: Node3D):
	if body is Actor and enabled:
		body.wind_columns_inside.append(self)

func _on_body_exited(body: Node3D):
	if body is Actor:
		body.wind_columns_inside.erase(self)

func _on_tree_exiting():
	for actor in Actor.ALL_EVER_MADE:
		if is_instance_valid(actor):
			actor.wind_columns_inside.erase(self)

func serialize() -> Dictionary:
	return {"enabled": enabled}
	
func deserialize(state: Dictionary) -> void:
	self.enabled = state["enabled"]
	if enabled:
		_particles.emitting = true
