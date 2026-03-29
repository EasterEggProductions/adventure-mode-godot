extends Sprite3D

@export var target : Node
@export var refresh : bool
@onready var bar_health : ProgressBar = $SubViewport/VBoxContainer/bar_health
@onready var player_name : Label = $SubViewport/VBoxContainer/nametag

# When the node enters the scene tree for the first time, this will be
# called to initialize the progress bar's max value and current fill value.
# Will also initialize the player name text.
func _ready() -> void:
	player_name.text = target.name
	bar_health.max_value = target.character.health_max
	bar_health.value = target.character.health_current

# Called every frame to update the current progress bar fill and player name
func _process(_delta: float) -> void:
	if refresh:   
		player_name.text = target.name
		bar_health.value = target.character.health_current