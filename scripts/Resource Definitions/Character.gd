extends Resource
class_name Character 

## 2D portrait image of character 
@export var portrait : Texture2D 
## Name of character to display, if different from resource name.  
@export var given_name : String

## Using standard RPG set of attributes
## Expected you would change or extend upon this for your own things
@export_group("Attributes")
## Strength of character 
@export var strength : int
## Mobility of the character
@export var dexterity : int
## Physical robustness of character
@export var constitution : int
## Intellectual capacity of character, analytical reasoning
@export var inteligence : int
## Experiential or intuitive capacity of character, intuitive reasoning
@export var wisdom : int
## Social reasoning capacity of character, mammals only, requires third level of brain.
@export var charisma : int

## A lot is duplicated here from thing to thing, and these all share the trait of 
## being the bars that are displayed on the screen. Perhaps these should also be a resource? 
## Even if they do not regen by default, they would share a lot of functionality in terms 
## of having a max value, current value, a possible 'current max' value for things like 
## effects causing max health or stam to go down. So sleep on that mister thinkerman
@export_group("Stats")

## Default maximum health
@export var health_max = 10.0
## current health 
@export var health_current = 10.0
## Amount per second that health regenerates
@export var health_regen = 0.0
## Time after drain that regeneration kicks in
@export var health_regen_delay = 3.0
var health_regen_timer = 0.0
## Default maximum stamina
@export var stamina_max = 20.0 
## current stamina 
@export var stamina_current = 5.0
## Amount per second that stamina regenerates
@export var stamina_regen = 1.0
## Time after drain that regeneration kicks in
@export var stamina_regen_delay = 3.0
var stamina_regen_timer = 0.0
## Default maximum poise
@export var poise_max = 15.0
## current poise 
@export var poise_current = 0.0
## Amount per second that poise regenerates
@export var poise_regen = 1.0
## Time after drain that regeneration kicks in
@export var poise_regen_delay = 3.0
var poise_regen_timer = 0.0
@export var alive = true

## It is expected that the inventory here will be somewhat robust. 
## With all items belonging to the character kept in a dictionary,
## And then those items /referenced/ in various slots and such.
## With only the core inventory dictionary adding or removing things
@export_group("Inventory")
@export var my_item : InventoryItem
@export var my_otherItem : InventoryItem

## Item held in right hand, weapon, shield, etc 
@export var hand_right : Accessory
## Item held in left hand, awards, accolades, etc
@export var hand_left : Accessory

@export_group("Dress Up")
## Base skeleton used for effects such as dissolve or undead
@export var under_skeleton : Garment
## The skin to display when the character is naked
@export var base_skin : Garment
## The garments applied. These can be hand set in the inspector for NPCs,
## but for players it is intended that equipped items will control this. 
@export var outfit : Array[Garment]


## Sets attributes to max. For respawn, revitalize.
func reset(): 
	alive = true
	health_current = health_max
	stamina_current = stamina_max
	poise_current = poise_max

func stats_regen(delta : float):
	health_regen_timer -= delta
	stamina_regen_timer -= delta
	poise_regen_timer -= delta
	if health_regen_timer <= 0:
		health_current = clamp(health_current + (delta * health_regen), -100, health_max)
	if stamina_regen_timer <= 0:
		stamina_current = clamp(stamina_current + (delta * stamina_regen), -100, stamina_max)
	if poise_regen_timer <= 0:
		poise_current = clamp(poise_current + (delta * poise_regen), 0, poise_max)
