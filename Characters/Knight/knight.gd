extends KinematicBody2D

#Global Variables
var frame = 0
export var id: int

#Attributes
export var percentage = 0
export var stocks = 3
export var weight = 100

#Knockback
var hdecay
var vdecay
var knockback
var hitstun
var connected:bool

#Ground Variables
var velocity = Vector2(0,0)
var dash_duration = 8

#Landing Variables
var landing_frames = 10
var lag_frames = 6
var jump_squat = 6
var perfect_wavedash_modifier = 1

#Air Variables
var fastfall = false
var airJump = 0
export var airJumpMax = 1

#Ledges
var last_ledge = false
var regrab = 30
var catch = false

#Hitboxes
export var hitbox: PackedScene
var selfState

#Onready variables
onready var GroundL = get_node("Raycasts/GroundL")
onready var GroundR = get_node("Raycasts/GroundR")
onready var Ledge_Grab_F = get_node("Raycasts/Ledge_Grab_F")
onready var Ledge_Grab_B = get_node("Raycasts/Ledge_Grab_B")
onready var states = $State
onready var anim = $Sprite/AnimationPlayer

#Knight's main attributes
var RUNSPEED = 340
var DASHSPEED = 390
var WALKSPEED = 200
var GRAVITY = 1800
var JUMPFORCE = 500
var MAX_JUMPFORCE = 800
var DOUBLEJUMPFORCE = 1000
var MAXAIRSPEED = 300
var AIR_ACCEL = 25
var FALLSPEED = 60
var FALLINGSPEED = 600
var MAXFALLSPEED = 900
var TRACTION = 40
var ROLL_DISTANCE = 350
var air_dodge_speed = 500
var UP_B_LAUNCHSPEED = 700

func create_hitbox(width, height, damage, angle, base_kb, kb_scaling, duration, type, points, angle_flipper, hitlag = 1):
	var hitbox_instance = hitbox.instance()
	self.add_child(hitbox_instance)
	if direction() == 1:
		hitbox_instance.set_parameters(width, height, damage, angle, base_kb, kb_scaling, duration, type, points, angle_flipper, hitlag)
	else:
		var flip_x_points = Vector2(-points.x, points.y)
		hitbox_instance.set_parameters(width, height, damage, -angle + 180, base_kb, kb_scaling, duration, type, flip_x_points, angle_flipper, hitlag)
	return hitbox_instance

func updateframes(delta):
	frame += 1

func turn(direction):
	var dir = 0
	if direction:
		dir = -1
	else:
		dir = 1
	$Sprite.set_flip_h(direction)
	Ledge_Grab_F.set_cast_to(Vector2(dir*abs(Ledge_Grab_F.get_cast_to().x), Ledge_Grab_F.get_cast_to().y))
	Ledge_Grab_F.position.x = dir * abs(Ledge_Grab_F.position.x)
	Ledge_Grab_B.position.x = -dir * abs(Ledge_Grab_B.position.x)
	Ledge_Grab_B.set_cast_to(Vector2(-dir*abs(Ledge_Grab_F.get_cast_to().x), Ledge_Grab_F.get_cast_to().y))
	
func direction():
	if Ledge_Grab_F.get_cast_to().x > 0:
		return 1
	else:
		return -1

func frame():
	frame = 0

func play_animation(animation_name):
	anim.play(animation_name)

func reset_Jumps():
	airJump = airJumpMax

func reset_ledge():
	last_ledge = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$ID.text = "P" + str(id)

func _physics_process(delta):
	$Frames.text = str(frame)
	selfState = states.text
	$Percent.text = str(percentage) + "%"

#Tilt Attacks
func FORWARD_TILT():
	if frame == 14:
		create_hitbox(28, 35, 11, 10, 3, 120, 5, 'normal', Vector2(70, 6), 0, 1)
	if frame >= 24: #when exitable
		return true

func DOWN_TILT():
	if frame == 14:
		create_hitbox(35, 10, 8, 90, 3, 120, 5, 'normal', Vector2(61, 28), 0, 1)
	if frame >= 27: #when exitable
		return true

func UP_TILT(): # needs tweaking
	if frame == 16:
		create_hitbox(56, 56, 15, 90, 3, 120, 5, 'normal', Vector2(13, -75), 0, 1)
	if frame >= 32: #when exitable
		return true

func JAB():
	if frame == 12:
		create_hitbox(29, 29, 5, 10, 1, 120, 5, 'normal', Vector2(21, 8), 0, 1)
	if frame >= 24: #when exitable
		return true

func JAB2():
	if frame == 1:
		create_hitbox(29, 29, 4, 10, 1, 120, 5, 'normal', Vector2(21, 8), 0, 1)
	if frame >= 11: #when exitable
		return true

#Aerial Attacks
# modelled after fox aerials
func NAIR():
	if frame == 1:
		create_hitbox(56, 56, 12, 361, 0, 100, 3, 'normal', Vector2(0, 0), 0, 0.4)
	if frame > 1:
		if connected == true:
			if frame == 36:
				connected = false
				return true
		else:
			if frame == 5:
				create_hitbox(46, 56, 9, 361, 0, 100, 10, 'normal', Vector2(0, 0), 0, 0.1)
			if frame == 36:
				return true

func UAIR():
	if frame == 2:
		create_hitbox(32, 36, 5, 90, 130, 0, 2, 'normal', Vector2(0, -45), 0, 1)
	if frame == 6:
		create_hitbox(56, 46, 10, 90, 20, 108, 3, 'normal', Vector2(0, -48), 0, 2)
	if frame == 15:
		return true

func BAIR():
	if frame == 2:
		create_hitbox(52, 55, 15, 45, 1, 100, 5, 'normal', Vector2(-50, 0), 6, 1)
	if frame > 1:
		if connected == true:
			if frame == 18:
				connected = false
				return true
		else:
			if frame == 7:
				create_hitbox(52, 55, 5, 45, 3, 140, 10, 'normal', Vector2(-50, 0), 6, 1)
			if frame == 18:
				return true

func FAIR():
	if frame == 2:
		create_hitbox(35, 47, 3, 76, 10, 150, 3, 'normal', Vector2(60, -7), 0, 1)
	if frame == 11:
		create_hitbox(35, 47, 3, 76, 10, 150, 3, 'normal', Vector2(60, -7), 0, 1)
	if frame == 18:
		return true

func DAIR():
	if frame == 2:
		create_hitbox(36, 58, 2, 290, 140, 0, 2, 'normal', Vector2(28, 17), 0, 1)
	if frame == 3:
		create_hitbox(36, 58, 2, 290, 140, 0, 2, 'normal', Vector2(28, 17), 0, 1)
	if frame == 5:
		create_hitbox(36, 58, 2, 290, 140, 0, 2, 'normal', Vector2(28, 17), 0, 1)
	if frame == 7:
		create_hitbox(36, 58, 2, 290, 140, 0, 2, 'normal', Vector2(28, 17), 0, 1)
	if frame == 9:
		create_hitbox(36, 58, 2, 290, 140, 0, 2, 'normal', Vector2(28, 17), 0, 1)
	if frame == 11:
		create_hitbox(36, 58, 2, 290, 140, 0, 2, 'normal', Vector2(28, 17), 0, 1)
	if frame == 14:
		create_hitbox(36, 58, 2, 290, 140, 0, 2, 'normal', Vector2(28, 17), 0, 1)
	if frame == 17:
		return true

func reset():
	percentage = 0
	#stocks -= 1
	weight = 100
	velocity = Vector2(0,0)
