extends Sprite3D
class_name ActorNametag

@export var target : Actor
@export var refresh : bool
@onready var bar_health : ProgressBar = $SubViewport/VBoxContainer/bar_health
@onready var name_label : Label = $SubViewport/VBoxContainer/nametag

var prev_health = 0

enum VisState {NEVER, ALWAYS, ALIVE, CHANGE}
@export var vState = VisState.CHANGE
## Time from some change until fading out 
@export var fade_delay = 3.0
## Time of the fade out
@export var fade_time = 0.5

var tween : Tween
var timer : float = 0

# When the node enters the scene tree for the first time, this will be
# called to initialize the progress bar's max value and current fill value.
# Will also initialize the player name text.
func _ready() -> void:
	if vState == VisState.CHANGE:
		modulate = Color.TRANSPARENT
		prev_health = target.character.health_current
	name_label.text = target.character.given_name
	bar_health.max_value = target.character.health_max
	bar_health.value = target.character.health_current

# Called every frame to update the current progress bar fill and player name
func _process(_delta: float) -> void:
	if vState == VisState.ALWAYS:   
		name_label.text = target.character.given_name
		bar_health.value = target.character.health_current
	elif vState == VisState.ALIVE: 
		if target.character.health_current > 0:
			name_label.text = target.character.given_name
			bar_health.value = target.character.health_current
		else: 
			timer = 0
			fade_timer()
	elif vState == VisState.CHANGE: # For Enemies
		timer -= _delta
		if prev_health != target.character.health_current:
			prev_health = target.character.health_current
			bar_health.value = target.character.health_current
			start_fade_timer()
		fade_timer()

func set_nametag_visibility(new_state : VisState):
	vState = new_state
	visible = vState != VisState.NEVER
	if vState == VisState.ALIVE or vState == VisState.ALWAYS:
		modulate = Color.WHITE
	

func start_fade_timer():
	timer = fade_delay
	if tween != null:
		tween.stop()
	modulate = Color.WHITE

func fade_timer():
	if timer > 0 or modulate.a <= 0:
		return
	if tween != null:
		tween.stop()
	tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, fade_time)