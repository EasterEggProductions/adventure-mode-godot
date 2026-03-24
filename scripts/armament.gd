extends Node3D

class_name Armament # Weapon of offense or armor of defense that may be taken in hand to cast at in wrath at another.

@export var damage = 4
var ouchtime = false
@onready var hitbox = $hitbox
@onready var hitbox_vis = $hitbox/hitbox_vis
@onready var trail = $trail_weapon

var wielder : Actor # Thrall that wields this weapon
var leftHandHeld = false 
var attackID : int # random number to help prevent multi hits
@export var hit_effect : PackedScene
@export var block_effect : PackedScene

@export var moveset : MovementPackage

enum AttackState {HIT, MISS, BLOCKED}

var cur_strike_data

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if ouchtime:
		hurtbox_check()
		if leftHandHeld and wielder.prop_L_hurtbox == false:
			ouchtime_end()
		elif wielder.prop_R_hurtbox == false:
			ouchtime_end()


func equip_armament(new_wielder : Actor, left_hand : bool) -> void:
	wielder = new_wielder
	leftHandHeld = left_hand

func activate_strike(dvalues : Dictionary) -> void:
	if OS.is_debug_build():
		hitbox_vis.visible = true

	attackID = randi()
	if dvalues == null:
		cur_strike_data = {"physical":1.0 * damage}
	else:
		cur_strike_data = dvalues

	for box in wielder.hurtboxes:
		hitbox.add_exception(box)
	hitbox.force_shapecast_update()
	ouchtime = true
	trail.restart()

	# Pause for effect
#	await get_tree().create_timer(duration).timeout


func ouchtime_end():
	hitbox_vis.visible = false
	hitbox.clear_exceptions()
	ouchtime = false
	trail.stop() 

func hurtbox_check() -> void:	
	for x in range(hitbox.get_collision_count()):
		
		#print("OUCH!" + hitbox.get_collider(x).name)
		hitbox.add_exception_rid(hitbox.get_collider_rid(x))
		var hit_actor = awful_practice_find_parent_actor(hitbox.get_collider(x))
		var att_result = hit_actor.take_damage(cur_strike_data, attackID)
		match att_result:
			AttackState.HIT:
				wielder.attack_hit.emit(hit_actor, attackID) 
				spawn_hit_effect(hit_effect, hitbox.get_collision_point(x), hitbox.get_collision_point(x) + hitbox.get_collision_normal(x))
				if hit_actor.character.health_current <= 0:
					wielder.killed_something.emit()
			AttackState.MISS:
				pass 
			AttackState.BLOCKED:
				print("Attack blocked!") 	
				spawn_hit_effect(block_effect, hitbox.get_collision_point(x), hitbox.get_collision_point(x) + hitbox.get_collision_normal(x))			
			_:
				pass

func spawn_hit_effect(effect : PackedScene, pos : Vector3, lookAt : Vector3):
	var nHit = effect.instantiate()
	get_tree().root.add_child(nHit)
	nHit.global_position = pos
	nHit.look_at(lookAt)
	nHit.emitting = true
		

func awful_practice_find_parent_actor(node : Node3D):
	if node is Actor:
		return node
	else:
		return awful_practice_find_parent_actor(node.get_parent())