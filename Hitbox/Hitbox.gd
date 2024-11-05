extends Area2D

var parent = get_parent()
export var width = 300
export var height = 400
export var damage = 50
export var angle = 90
export var base_kb = 100 #knockback
export var kb_scaling = 2
export var duration = 1500
export var hitlag_modifier = 1 #both players enter hitlag state on some moves like falcon punch
export var type = 'normal' #just relevant for effects
export var angle_flipper = 0
onready var hitbox = get_node("Hitbox_Shape")
onready var parentState = get_parent().selfState
var knockbackVal #final calculated knockback
var framez = 0.0
var player_list = []

func set_parameters(w,h,d,a,b_kb,kb_s,dur,t,p,af,hit,parent=get_parent()):
	self.position = Vector2(0, 0)
	player_list.append(parent)
	player_list.append(self) #you don't want the hitbox to collide with itself (might cause issues later)
	width = w
	height = h
	damage = d
	angle = a
	base_kb = b_kb
	kb_scaling = kb_s
	duration = dur
	type = t
	self.position = p
	angle_flipper = af
	hitlag_modifier = hit
	update_extents()
	connect("area_entered", self, "Hitbox_Collide")
	set_physics_process(true)

func update_extents():
	hitbox.shape.extents = Vector2(width, height)

func _ready():
	hitbox.shape = RectangleShape2D.new() #just in case? might be redundant
	set_physics_process(false)
	pass

func _physics_process(delta):
	if framez < duration:
		framez += 1
	elif framez == duration:
		Engine.time_scale = 1
		queue_free()
		return
	if get_parent().selfState != parentState:
		Engine.time_scale = 1
		queue_free()
		return
