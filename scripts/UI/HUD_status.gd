extends Control

var thrall
var character : Character
@onready var bar_health : ProgressBar = $bar_health 
@onready var bar_stamina : ProgressBar = $bar_stamina 
@onready var bar_poise : ProgressBar = $bar_poise 

var px_per_point = 15

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if is_instance_valid(thrall):
		bar_health.value = character.health_current 
		bar_stamina.value = character.stamina_current 
		bar_poise.value = character.poise_current 



func inspect_new_thrall(new_thrall : Actor):
	thrall = new_thrall
	character = thrall.character
	bar_health.size.x = character.health_max * px_per_point
	bar_health.max_value = character.health_max
	bar_stamina.size.x = character.stamina_max * px_per_point
	bar_stamina.max_value = character.stamina_max
	bar_poise.size.x = character.poise_max * px_per_point
	bar_poise.max_value = character.poise_max

	