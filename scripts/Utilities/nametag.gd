extends Label3D

@export var target : Node 
@export var refresh : bool

func _ready() -> void:
    text = target.name

func _process(_delta: float) -> void:
    if refresh:
        text = target.name