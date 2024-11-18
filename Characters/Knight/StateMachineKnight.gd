extends StateMachine
onready var id = parent.id
const WALK_THRESHOLD = 0.3 # Start walking at 30% stick tilt, maybe make this an export var for stick sens
const DASH_THRESHOLD = 0.5

func _ready():
	add_state('STAND')
	add_state('JUMP_SQUAT')
	add_state('SHORT_HOP')
	add_state('FULL_HOP')
	add_state('DASH')
	add_state('RUN')
	add_state('WALK')
	add_state('MOONWALK')
	add_state('TURN')
	add_state('CROUCH')
	add_state('AIR')
	add_state('LANDING')
	add_state('LEDGE_CATCH')
	add_state('LEDGE_HOLD')
	add_state('LEDGE_CLIMB')
	add_state('LEDGE_JUMP')
	add_state('LEDGE_ROLL')
	add_state('SHIELD')
	add_state('HITFREEZE')
	add_state('HITSTUN')
	add_state('GROUND_ATTACK')
	add_state('UP_TILT')
	add_state('DOWN_TILT')
	add_state('FORWARD_TILT')
	add_state('JAB')
	add_state('JAB2')
	add_state('AIR_ATTACK')
	add_state('NAIR')
	add_state('UAIR')
	add_state('BAIR')
	add_state('FAIR')
	add_state('DAIR')
	call_deferred("set_state", states.STAND)

func state_logic(delta):
	parent.updateframes(delta)
	parent._physics_process(delta)
	if parent.regrab > 0:
		parent.regrab -= 1
	parent.hit_pause(delta)

func get_transition(delta):
	parent.move_and_slide_with_snap(parent.velocity*2,Vector2.ZERO,Vector2.UP)
	
	if Landing() == true:
		parent.frame()
		return states.LANDING
	
	if Falling() == true:
		return states.AIR
		
	if Ledge() == true:
		parent.frame()
		return states.LEDGE_CATCH
	else:
		parent.reset_ledge()
	
	
	if Input.is_action_just_pressed("shield_%s" % id) && TILT():
		parent.frame()
		return states.SHIELD
	
	if Input.is_action_just_pressed("attack_%s" % id) && TILT() == true:
		parent.frame()
		return states.GROUND_ATTACK
	
	if Input.is_action_just_pressed("attack_%s" % id) && AERIAL() == true:
		if Input.is_action_pressed("up_%s" % id):
			parent.frame()
			return states.UAIR
		if Input.is_action_pressed("down_%s" % id):
			parent.frame()
			return states.DAIR
		match parent.direction():
			1: #facing right
				if Input.is_action_pressed("left_%s" % id):
					parent.frame()
					return states.BAIR
				if Input.is_action_pressed("right_%s" % id):
					parent.frame()
					return states.FAIR
			-1:
				if Input.is_action_pressed("left_%s" % id):
					parent.frame()
					return states.FAIR
				if Input.is_action_pressed("right_%s" % id):
					parent.frame()
					return states.BAIR
		parent.frame()
		return states.NAIR

	match state:
		states.STAND:
			parent.reset_Jumps()
			var right_strength = Input.get_action_strength("right_%s" % id)
			var left_strength = Input.get_action_strength("left_%s" % id)

			if Input.is_action_just_pressed("jump_%s" % id):
				parent.frame()
				return states.JUMP_SQUAT
			if Input.is_action_just_pressed("down_%s" % id):
				parent.frame()
				return states.CROUCH

			# Check for walking vs dashing based on stick values
			if right_strength >= WALK_THRESHOLD:
				if right_strength >= DASH_THRESHOLD:
					parent.velocity.x = parent.DASHSPEED
					parent.frame()
					parent.turn(false)
					return states.DASH
				else:
					parent.frame()
					return states.WALK
			elif left_strength >= WALK_THRESHOLD:
				if left_strength >= DASH_THRESHOLD:
					parent.velocity.x = -parent.DASHSPEED
					parent.frame()
					parent.turn(true)
					return states.DASH
				else:
					parent.frame()
					return states.WALK
					
			# Handle friction when standing
			if parent.velocity.x > 0 and state == states.STAND:
				parent.velocity.x += -parent.TRACTION*1
				parent.velocity.x = clamp(parent.velocity.x,0,parent.velocity.x)
			elif parent.velocity.x < 0 and state == states.STAND:
				parent.velocity.x += parent.TRACTION*1
				parent.velocity.x = clamp(parent.velocity.x,parent.velocity.x,0)

		states.JUMP_SQUAT:
			if parent.frame == parent.jump_squat:
				if Input.is_action_pressed("shield_%s" % id) and (Input.is_action_pressed("left_%s" % id) or Input.is_action_pressed("right_%s" % id)): #basic wavedash
					print('wavedash')
					if Input.is_action_pressed("right_%s" % id):
						parent.velocity.x = parent.air_dodge_speed/parent.perfect_wavedash_modifier
					if Input.is_action_pressed("left_%s" % id):
						parent.velocity.x = -parent.air_dodge_speed/parent.perfect_wavedash_modifier
					#parent.states.text = 'WAVEDASH'
					parent.lag_frames = 6
					parent.frame()
					return states.LANDING
				if not Input.is_action_pressed("jump_%s" % id):
					parent.velocity.x = lerp(parent.velocity.x, 0, 0.08)
					parent.frame()
					return states.SHORT_HOP
				else:
					parent.velocity.x = lerp(parent.velocity.x, 0, 0.08)
					parent.frame()
					return states.FULL_HOP

		states.SHORT_HOP:
			parent.velocity.y = -parent.JUMPFORCE
			parent.frame()
			return states.AIR

		states.FULL_HOP:
			parent.velocity.y = -parent.MAX_JUMPFORCE
			parent.frame()
			return states.AIR

		states.DASH:
			if Input.is_action_just_pressed("jump_%s" % id):
				parent.frame()
				return states.JUMP_SQUAT
			
			if Input.is_action_pressed("left_%s" % id):
				if parent.velocity.x > 0:
					parent.frame()
				parent.velocity.x = -parent.DASHSPEED
				if parent.frame <= parent.dash_duration - 1:
					if Input.is_action_just_pressed("down_%s" % id):
						parent.frame()
						return states.MOONWALK
					parent.turn(true)
					return states.DASH
				else:
					parent.turn(true)
					parent.frame()
					return states.RUN
			elif Input.is_action_pressed("right_%s" % id):
				if parent.velocity.x < 0:
					parent.frame()
				parent.velocity.x = parent.DASHSPEED
				if parent.frame <= parent.dash_duration - 1:
					if Input.is_action_just_pressed("down_%s" % id):
						parent.frame()
						return states.MOONWALK
					parent.turn(false)
					return states.DASH #redundant
				else:
					parent.turn(false)
					parent.frame()
					return states.RUN
			else:
				if parent.frame >= parent.dash_duration-1:
					for state in states:
						if state != 'JUMP_SQUAT':
							parent.frame()
							return states.STAND

		states.RUN:
			if Input.is_action_just_pressed("jump_%s" % id):
				parent.frame()
				return states.JUMP_SQUAT
			if Input.is_action_just_pressed("down_%s" % id):
				parent.frame()
				return states.CROUCH
			if Input.is_action_pressed("left_%s" % id):
				if parent.velocity.x <= 0:
					parent.velocity.x = -parent.RUNSPEED
					parent.turn(true)
				else:
					parent.frame()
					return states.TURN
			elif Input.is_action_pressed("right_%s" % id):
				if parent.velocity.x >= 0:
					parent.velocity.x = parent.RUNSPEED
					parent.turn(false)
				else:
					parent.frame()
					return states.TURN
			else:
				parent.frame()
				return states.STAND

		states.TURN:
			if Input.is_action_just_pressed("jump_%s" % id):
				parent.frame()
				return states.JUMP_SQUAT
			if parent.velocity.x > 0:
				parent.turn(true)
				parent.velocity.x += -parent.TRACTION*2
				parent.velocity.x = clamp(parent.velocity.x, 0, parent.velocity.x)
			elif parent.velocity.x < 0:
				parent.turn(false)
				parent.velocity.x += parent.TRACTION*2
				parent.velocity.x = clamp(parent.velocity.x, parent.velocity.x, 0)
			else:
				if not Input.is_action_pressed("left_%s" % id) and not Input.is_action_pressed("right_%s" % id):
					parent.frame()
					return states.STAND
				else:
					parent.frame()
					return states.RUN

		states.MOONWALK:
			if Input.is_action_just_pressed("jump_%s" % id):
				parent.frame()
				return states.JUMP_SQUAT
			elif Input.is_action_pressed("left_%s" % id) && parent.direction() == 1:
				if parent.velocity.x > 0:
					parent.frame()
				parent.velocity.x += -parent.AIR_ACCEL * Input.get_action_strength("left_%s" % id)
				parent.velocity.x = clamp(parent.velocity.x, -parent.DASHSPEED, parent.velocity.x)
				if parent.frame <= parent.dash_duration * 2:
					parent.turn(false)
					return states.MOONWALK
				else:
					parent.turn(true)
					parent.frame()
					return states.STAND
			elif Input.is_action_pressed("right_%s" % id) && parent.direction() == -1:
				if parent.velocity.x < 0:
					parent.frame()
				parent.velocity.x += parent.AIR_ACCEL * Input.get_action_strength("right_%s" % id)
				parent.velocity.x = clamp(parent.velocity.x, parent.velocity.x, parent.DASHSPEED)
				if parent.frame <= parent.dash_duration * 2:
					parent.turn(true)
					return states.MOONWALK
				else:
					parent.turn(false)
					parent.frame()
					return states.STAND
			
			else:
				if parent.frame >= parent.dash_duration-1:
					for state in states:
						if state != "JUMP_SQUAT":
							return states.STAND

		states.WALK: # create transitions into this state
			
			if Input.is_action_just_pressed("jump_%s" % id):
				parent.frame()
				return states.JUMP_SQUAT
			if Input.is_action_just_pressed("down_%s" % id):
				parent.frame()
				return states.CROUCH
			if Input.is_action_pressed("left_%s" % id):
				parent.velocity.x = -parent.WALKSPEED * Input.get_action_strength("left_%s" % id)
				parent.turn(true)
			elif Input.is_action_pressed("right_%s" % id):
				parent.velocity.x = parent.WALKSPEED * Input.get_action_strength("right_%s" % id)
				parent.turn(false)
			else:
				parent.frame()
				return states.STAND

		states.CROUCH:
			if Input.is_action_just_pressed("jump_%s" % id):
				parent.frame()
				return states.JUMP_SQUAT
			if Input.is_action_just_released("down_%s" % id):
				parent.frame()
				return states.STAND
			elif parent.velocity.x > 0:
				if parent.velocity.x > parent.RUNSPEED:
					parent.velocity.x += -(parent.TRACTION*4)
					parent.velocity.x = clamp(parent.velocity.x, 0, parent.velocity.x)
				else:
					parent.velocity.x += -(parent.TRACTION/2)
					parent.velocity.x = clamp(parent.velocity.x, 0, parent.velocity.x)
			elif parent.velocity.x < 0:
				if abs(parent.velocity.x) > parent.RUNSPEED:
					parent.velocity.x += (parent.TRACTION*4)
					parent.velocity.x = clamp(parent.velocity.x, parent.velocity.x, 0)
				else:
					parent.velocity.x += (parent.TRACTION/2)
					parent.velocity.x = clamp(parent.velocity.x, parent.velocity.x, 0)

		states.AIR:
			AIRMOVEMENT()
			# double jumps
			# maybe switch to is_action_pressed allow held jump to continue applying force
			if Input.is_action_just_pressed("jump_%s" % id) and parent.airJump > 0:
				parent.fastfall = false
				parent.velocity.x = 0
				parent.velocity.y = -parent.DOUBLEJUMPFORCE
				parent.airJump -= 1
				if Input.is_action_pressed("left_%s" % id):
					parent.velocity.x = -parent.MAXAIRSPEED
				elif Input.is_action_pressed("right_%s" % id):
					parent.velocity.x = parent.MAXAIRSPEED

		states.LANDING:
			if parent.frame <= parent.landing_frames + parent.lag_frames:
				#if parent.frame == 1:
				#	pass
				if parent.velocity.x > 0:
					parent.velocity.x = parent.velocity.x - parent.TRACTION/2
					parent.velocity.x = clamp(parent.velocity.x, 0, parent.velocity.x)
				elif parent.velocity.x < 0:
					parent.velocity.x = parent.velocity.x + parent.TRACTION/2
					parent.velocity.x = clamp(parent.velocity.x, parent.velocity.x, 0)
				if Input.is_action_just_pressed("jump_%s" % id):
					parent.frame()
					return states.JUMP_SQUAT
			else:
				if Input.is_action_just_pressed("down_%s" % id):
					parent.lag_frames = 0
					parent.frame()
					parent.reset_Jumps()
					return states.CROUCH
				else:
					parent.lag_frames = 0
					parent.frame()
					parent.reset_Jumps()
					return states.STAND
				parent.lag_frames = 0

		states.LEDGE_CATCH:
			if parent.frame > 7:
				parent.lag_frames = 0
				parent.reset_Jumps()
				parent.frame()
				return states.LEDGE_HOLD

		states.LEDGE_HOLD:
			if parent.frame >= 390:
				self.parent.position.y += -25
				parent.frame()
				return states.AIR #return states.TUMBLE
			if Input.is_action_just_pressed("down_%s" % id):
				parent.fastfall = true
				parent.regrab = 30
				parent.reset_ledge()
				self.parent.position.y += -25
				parent.catch = false
				parent.frame()
				return states.AIR
			elif parent.Ledge_Grab_F.get_cast_to().x > 0:
				if Input.is_action_just_pressed("left_%s" % id):
					parent.velocity.x = (parent.AIR_ACCEL/2)
					parent.regrab = 30
					parent.reset_ledge()
					self.parent.position.y += -25
					parent.catch = false
					parent.frame()
					return states.AIR
				elif Input.is_action_just_pressed("right_%s" % id):
					parent.frame()
					return states.LEDGE_CLIMB
				elif Input.is_action_just_pressed("shield_%s" % id):
					parent.frame()
					return states.LEDGE_ROLL
				elif Input.is_action_just_pressed("jump_%s" % id):
					parent.frame()
					return states.LEDGE_JUMP
					
			elif parent.Ledge_Grab_F.get_cast_to().x < 0:
				if Input.is_action_just_pressed("right_%s" % id):
					parent.velocity.x = parent.AIR_ACCEL/2
					parent.regrab = 30
					parent.reset_ledge()
					self.parent.position.y += -25
					parent.catch = false
					parent.frame()
					return states.AIR
				elif Input.is_action_just_pressed("left_%s" % id):
					parent.frame()
					return states.LEDGE_CLIMB
				elif Input.is_action_just_pressed("shield_%s" % id):
					parent.frame()
					return states.LEDGE_ROLL
				elif Input.is_action_just_pressed("jump_%s" % id):
					parent.frame()
					return states.LEDGE_JUMP

		states.LEDGE_CLIMB:
			if parent.frame == 1:
				pass
			if parent.frame == 5:
				parent.position.y += -20
			if parent.frame == 10:
				parent.position.y += -20
			if parent.frame == 15:
				parent.position.y += -40
				parent.position.x += 25 * parent.direction()
			if parent.frame == 22:
				parent.position.y += -25
				parent.catch = false
				parent.position.x += 25 * parent.direction()
			if parent.frame == 25:
				parent.velocity.y = 0
				parent.velocity.x = 0
				parent.move_and_collide(Vector2(parent.direction() * 20, 50))
			if parent.frame == 30:
				parent.reset_ledge()
				parent.frame()
				return states.STAND

		states.LEDGE_JUMP:
			if parent.frame > 14:
				if Input.is_action_just_pressed("attack_%s" % id):
					parent.frame()
					return states.AIR_ATTACK
				if Input.is_action_just_pressed("special_%s" % id):
					parent.frame()
					return states.SPECIAL
			if parent.frame == 5:
				parent.reset_ledge()
				parent.position.y += -20
			if parent.frame == 10:
				parent.catch = false
				parent.position.y += -20
				if Input.is_action_just_pressed("jump_%s" % id) and parent.airJump > 0:
					parent.fastfall = false
					parent.velocity.y = -parent.DOUBLEJUMPFORCE
					parent.velocity.x = 0
					parent.airJump -= 1
					parent.frame()
					return states.AIR
			if parent.frame == 15:
				parent.position.y += -20
				parent.velocity.y = -parent.DOUBLEJUMPFORCE
				parent.velocity.x += 220 * parent.direction()
				if Input.is_action_just_pressed("jump_%s" % id) and parent.airJump > 0:
					parent.fastfall = false
					parent.velocity.y = -parent.DOUBLEJUMPFORCE
					parent.velocity.x = 0
					parent.airJump -= 1
					parent.frame()
					return states.AIR
				if Input.is_action_just_pressed("attack_%s" % id):
					parent.frame()
					return states.AIR_ATTACK
			elif parent.frame > 15 and parent.frame < 20:
				parent.velocity.y += parent.FALLSPEED
				if Input.is_action_just_pressed("jump_%s" % id) and parent.airJump > 0:
					parent.fastfall = false
					parent.velocity.y = -parent.DOUBLEJUMPFORCE
					parent.velocity.x = 0
					parent.airJump -= 1
					parent.frame()
					return states.AIR
				if Input.is_action_just_pressed("attack_%s" % id):
					parent.frame()
					return states.AIR_ATTACK
			if parent.frame == 20:
				parent.frame()
				return states.AIR

		states.LEDGE_ROLL:
			if parent.frame == 1:
				pass
			if parent.frame == 5:
				parent.position.y += -30
			if parent.frame == 10:
				parent.position.y += -30
			if parent.frame == 20:
				parent.position.y += -30
				parent.catch = false
			if parent.frame == 22:
				parent.position.y += -30
				parent.position.x += 50 * parent.direction()
				
			if parent.frame > 22 and parent.frame < 28:
				parent.position.x += 30 * parent.direction()
				
			if parent.frame == 29:
				parent.move_and_collide(Vector2(parent.direction() * 20, 50))
			if parent.frame == 30:
				parent.velocity.y = 0
				parent.velocity.x = 0
				parent.reset_ledge()
				parent.frame()
				return states.STAND

		states.SHIELD:
			if Input.is_action_just_pressed("jump_%s" % id):
				parent.frame()
				return states.JUMP_SQUAT
			if Input.is_action_just_released("shield_%s" % id):
				parent.frame()
				return states.STAND
			elif parent.velocity.x > 0:
				if parent.velocity.x > parent.RUNSPEED:
					parent.velocity.x += -(parent.TRACTION*4)
					parent.velocity.x = clamp(parent.velocity.x, 0, parent.velocity.x)
				else:
					parent.velocity.x += -(parent.TRACTION/2)
					parent.velocity.x = clamp(parent.velocity.x, 0, parent.velocity.x)
			elif parent.velocity.x < 0:
				if abs(parent.velocity.x) > parent.RUNSPEED:
					parent.velocity.x += (parent.TRACTION*4)
					parent.velocity.x = clamp(parent.velocity.x, parent.velocity.x, 0)
				else:
					parent.velocity.x += (parent.TRACTION/2)
					parent.velocity.x = clamp(parent.velocity.x, parent.velocity.x, 0)
			if parent.frame > 180: # 3 seconds
				parent.frame()
				return states.STAND

		states.HITFREEZE:
			if parent.freezeframes == 0:
				parent.frame()
				parent.velocity.x = kbx
				parent.velocity.y = kby
				parent.hdecay = hd
				parent.vdecay = vd
				return states.HITSTUN
			parent.position = pos #same position while in freezeframes

		states.HITSTUN:
			if parent.knockback >= 3: #hitstun threshhold
				var bounce = parent.move_and_collide(parent.velocity * delta)
				if bounce:
					parent.velocity = parent.velocity.bounce(bounce.normal) * 0.8
					parent.hitstun = round(parent.hitstun * 0.8)
			if parent.velocity.y < 0:
				parent.velocity.y += parent.vdecay * 0.5 * Engine.time_scale
				parent.velocity.y = clamp(parent.velocity.y, parent.velocity.y, 0)
			if parent.velocity.x < 0:
				parent.velocity.x += parent.hdecay * -0.4 * Engine.time_scale
				parent.velocity.x = clamp(parent.velocity.x, parent.velocity.x, 0)
			elif parent.velocity.x > 0:
				parent.velocity.x += parent.hdecay * -0.4 * Engine.time_scale
				parent.velocity.x = clamp(parent.velocity.x, 0, parent.velocity.x)
			
			if parent.frame >= parent.hitstun:
				if parent.knockback >= 24:
					parent.frame()
					#return states.TUMBLE
					return states.AIR
				else:
					parent.frame()
					return states.AIR
			elif parent.frame > 60 * 5:
				return states.AIR

		states.AIR_ATTACK:
			AIRMOVEMENT()
			if Input.is_action_pressed("up_%s" % id):
				parent.frame()
				return states.UAIR
			if Input.is_action_pressed("down_%s" % id):
				parent.frame()
				return states.DAIR
			match parent.direction():
				1:
					if Input.is_action_pressed("left_%s" % id):
						parent.frame()
						return states.BAIR
					if Input.is_action_pressed("right_%s" % id):
						parent.frame()
						return states.FAIR
				-1:
					if Input.is_action_pressed("left_%s" % id):
						parent.frame()
						return states.FAIR
					if Input.is_action_pressed("right_%s" % id):
						parent.frame()
						return states.BAIR
			parent.frame()
			return states.NAIR
			
		states.NAIR:
			AIRMOVEMENT()
			if parent.frame == 0:
				parent.NAIR()
			if parent.NAIR() == true:
				parent.lag_frames = 0
				parent.frame()
				return states.AIR
			### if we wanted to add l-cancelling/autocancels, do smth like this
			#elif parent.frame < 5 or parent.frame > 15:
			#	parent.lag_frames = 0
			#else:
			#	parent.lag_frames = 7
				
		states.UAIR:
			AIRMOVEMENT()
			if parent.frame == 0:
				parent.UAIR()
			if parent.UAIR() == true:
				parent.lag_frames = 0
				parent.frame()
				return states.AIR

		states.BAIR:
			AIRMOVEMENT()
			if parent.frame == 0:
				parent.BAIR()
			if parent.BAIR() == true:
				parent.lag_frames = 0
				parent.frame()
				return states.AIR

		states.FAIR:
			AIRMOVEMENT()
			if Input.is_action_just_pressed("jump_%s" % id) and parent.airJump > 0:
				parent.fastfall = false
				parent.velocity.x = 0
				parent.velocity.y = -parent.DOUBLEJUMPFORCE
				parent.airJump += -1
				if Input.is_action_pressed("left_%s" % id):
					parent.velocity.x = -parent.MAXAIRSPEED
				if Input.is_action_pressed("right_%s" % id):
					parent.velocity.x = parent.MAXAIRSPEED
				return states.AIR
			if parent.frame == 0:
				parent.FAIR()
			if parent.FAIR() == true:
				parent.lag_frames = 30
				parent.frame()
				return states.FAIR

		states.DAIR:
			AIRMOVEMENT()
			if parent.frame == 0:
				parent.DAIR()
			if parent.DAIR() == true:
				parent.lag_frames = 0
				parent.frame()
				return states.AIR

		states.GROUND_ATTACK:
			if Input.is_action_pressed("up_%s" % id):
				parent.frame()
				return states.UP_TILT
			if Input.is_action_pressed("down_%s" % id):
				parent.frame()
				return states.DOWN_TILT
			if Input.is_action_pressed("left_%s" % id):
				parent.turn(true)
				parent.frame()
				return states.FORWARD_TILT
			if Input.is_action_pressed("right_%s" % id):
				parent.turn(false)
				parent.frame()
				return states.FORWARD_TILT
			parent.frame()
			return states.JAB

		states.UP_TILT:
			if parent.frame == 0:
				parent.UP_TILT() #returns true if complete
				pass
			if parent.frame >= 1:
				if parent.velocity.x > 0:
					parent.velocity.x += -parent.TRACTION
					parent.velocity.x = clamp(parent.velocity.x, 0, parent.velocity.x)
				elif parent.velocity.x < 0:
					parent.velocity.x += parent.TRACTION * 3
					parent.velocity.x = clamp(parent.velocity.x, parent.velocity.x, 0)
			if parent.UP_TILT() == true:
				if Input.is_action_pressed("down_%s" % id):
					parent.frame()
					return states.CROUCH
				else:
					parent.frame()
					return states.STAND

		states.DOWN_TILT:
			if parent.frame == 0:
				parent.DOWN_TILT() #returns true if complete
				pass
			if parent.frame >= 1:
				if parent.velocity.x > 0:
					parent.velocity.x += -parent.TRACTION
					parent.velocity.x = clamp(parent.velocity.x, 0, parent.velocity.x)
				elif parent.velocity.x < 0:
					parent.velocity.x += parent.TRACTION
					parent.velocity.x = clamp(parent.velocity.x, parent.velocity.x, 0)
			if parent.DOWN_TILT() == true:
				if Input.is_action_pressed("down_%s" % id):
					parent.frame()
					return states.CROUCH
				else:
					parent.frame()
					return states.STAND

		states.FORWARD_TILT:
			if parent.frame == 0:
				parent.FORWARD_TILT() #returns true if complete
				pass
			if parent.frame >= 1:
				if parent.velocity.x > 0:
					parent.velocity.x += -parent.TRACTION * 3
					parent.velocity.x = clamp(parent.velocity.x, 0, parent.velocity.x)
				elif parent.velocity.x < 0:
					parent.velocity.x += parent.TRACTION * 3
					parent.velocity.x = clamp(parent.velocity.x, parent.velocity.x, 0)
			if parent.FORWARD_TILT() == true:
				if Input.is_action_pressed("down_%s" % id):
					parent.frame()
					return states.CROUCH
				else:
					parent.frame()
					return states.STAND

		states.JAB:
			if parent.frame == 0:
				parent.JAB() #returns true if complete
				pass
			if parent.frame >= 1:
				if parent.velocity.x > 0:
					parent.velocity.x += -parent.TRACTION * 3
					parent.velocity.x = clamp(parent.velocity.x, 0, parent.velocity.x)
				elif parent.velocity.x < 0:
					parent.velocity.x += parent.TRACTION * 3
					parent.velocity.x = clamp(parent.velocity.x, parent.velocity.x, 0)
			if parent.JAB() == true:
				if Input.is_action_pressed("attack_%s" % id):
					parent.frame()
					return states.JAB2
				if Input.is_action_pressed("down_%s" % id):
					parent.frame()
					return states.CROUCH
				else:
					parent.frame()
					return states.STAND

		states.JAB2:
			if parent.frame == 0:
				parent.JAB2() #returns true if complete
				pass
			if parent.frame >= 1:
				if parent.velocity.x > 0:
					parent.velocity.x += -parent.TRACTION * 3
					parent.velocity.x = clamp(parent.velocity.x, 0, parent.velocity.x)
				elif parent.velocity.x < 0:
					parent.velocity.x += parent.TRACTION * 3
					parent.velocity.x = clamp(parent.velocity.x, parent.velocity.x, 0)
			if parent.JAB2() == true:
				if Input.is_action_pressed("attack_%s" % id):
					parent.frame()
					return states.JAB
				if Input.is_action_pressed("down_%s" % id):
					parent.frame()
					return states.CROUCH
				else:
					parent.frame()
					return states.STAND

func enter_state(new_state, old_state):
	match new_state:
		states.STAND:
			parent.play_animation('idle')
			parent.states.text = 'STAND'
		states.DASH:
			parent.play_animation('dash')
			parent.states.text = 'DASH'
		states.WALK:
			parent.play_animation('walk')
			parent.states.text = 'WALK'
		states.MOONWALK:
			parent.play_animation('walk')
			parent.states.text = 'MOONWALK'
		states.TURN:
			parent.play_animation('turn')
			parent.states.text = 'TURN'
		states.CROUCH:
			parent.play_animation('crouchidle')
			parent.states.text = 'CROUCH'
		states.RUN:
			parent.play_animation('run')
			parent.states.text = 'RUN'
		states.JUMP_SQUAT:
			parent.play_animation('jump')
			parent.states.text = 'JUMP_SQUAT'
		states.SHORT_HOP:
			parent.play_animation('fall')
			parent.states.text = 'SHORT_HOP'
		states.FULL_HOP:
			parent.play_animation('fall')
			parent.states.text = 'FULL_HOP'
		states.AIR:
			parent.play_animation('fall')
			parent.states.text = 'AIR'
		states.LANDING:
			parent.play_animation('land')
			parent.states.text = 'LANDING'
		states.LEDGE_CATCH:
			parent.play_animation('ledgegrab')
			parent.states.text = 'LEDGE_CATCH'
		states.LEDGE_HOLD:
			parent.play_animation('ledgehang')
			parent.states.text = 'LEDGE_HOLD'
		states.LEDGE_JUMP:
			parent.play_animation('fall')
			parent.states.text = 'LEDGE_JUMP'
		states.LEDGE_CLIMB:
			parent.play_animation('ledgegetup')
			parent.states.text = 'LEDGE_CLIMB'
		states.LEDGE_ROLL:
			parent.play_animation('dodge') # change to roll eventually
			parent.states.text = 'LEDGE_ROLL'
		states.SHIELD:
			parent.play_animation('blocking')
			parent.states.text = 'SHIELD'
		states.HITFREEZE:
			parent.play_animation('hurt')
			parent.states.text = 'HITFREEZE'
		states.HITSTUN:
			parent.play_animation('hurt')
			parent.states.text = 'HITSTUN'
		states.AIR_ATTACK:
			parent.states.text = 'AIR_ATTACK'
		states.NAIR:
			parent.play_animation('nair')
			parent.states.text = 'NAIR'
		states.UAIR:
			parent.play_animation('uair')
			parent.states.text = 'UAIR'
		states.BAIR:
			parent.play_animation('bair')
			parent.states.text = 'BAIR'
		states.FAIR:
			parent.play_animation('fair')
			parent.states.text = 'FAIR'
		states.DAIR:
			parent.play_animation('dair')
			parent.states.text = 'DAIR'
		states.GROUND_ATTACK:
			parent.states.text = 'GROUND_ATTACK'
		states.UP_TILT:
			parent.play_animation('utilt')
			parent.states.text = 'UP_TILT'
		states.DOWN_TILT:
			parent.play_animation('dtilt')
			parent.states.text = 'DOWN_TILT'
		states.FORWARD_TILT:
			parent.play_animation('ftilt')
			parent.states.text = 'FORWARD_TILT'
		states.JAB:
			parent.play_animation('jab1')
			parent.states.text = 'JAB1'
		states.JAB2:
			parent.play_animation('jab2')
			parent.states.text = 'JAB2'

func exit_state(old_state, new_state):
	pass

func state_includes(state_array):
	for each_state in state_array:
		if state == each_state:
			return true
	return false

func TILT():
	if state_includes([states.STAND, states.MOONWALK, states.DASH, states.RUN, states.WALK, states.CROUCH]):
		return true

func AERIAL():
	if state_includes([states.AIR, states.DAIR, states.NAIR]):
		if !(parent.GroundL.is_colliding() and parent.GroundR.is_colliding()):
			return true
		else:
			return false

func AIRMOVEMENT():
	if parent.velocity.y < parent.FALLINGSPEED:
		parent.velocity.y += parent.FALLSPEED
	#	if Input.is_action_pressed("down_%s" % id) and parent.down_buffer == 1 and parent.velocity.y > -150 and not parent.fastfall:
	if Input.is_action_pressed("down_%s" % id) and parent.velocity.y > -150 and not parent.fastfall:
		parent.velocity.y = parent.MAXFALLSPEED
		parent.fastfall = true
	if parent.fastfall:
		parent.set_collision_mask_bit(2, false)
		parent.velocity.y = parent.MAXFALLSPEED
	
	if abs(parent.velocity.x) >= abs(parent.MAXAIRSPEED):
		if parent.velocity.x > 0:
			if Input.is_action_pressed("left_%s" % id):
				parent.velocity.x += -parent.AIR_ACCEL
			elif Input.is_action_pressed("right_%s" % id):
				parent.velocity.x = parent.velocity.x #what?
		if parent.velocity.x < 0:
			if Input.is_action_pressed("left_%s" % id):
				parent.velocity.x = parent.velocity.x #what?
			elif Input.is_action_pressed("right_%s" % id):
				parent.velocity.x += parent.AIR_ACCEL
	elif abs(parent.velocity.x) < abs(parent.MAXAIRSPEED):
		if Input.is_action_pressed("left_%s" % id):
			parent.velocity.x += -parent.AIR_ACCEL
		elif Input.is_action_pressed("right_%s" % id):
			parent.velocity.x += parent.AIR_ACCEL

	if not Input.is_action_pressed("left_%s" % id) and not Input.is_action_pressed("right_%s" % id):
		if parent.velocity.x < 0:
			parent.velocity.x += parent.AIR_ACCEL/5
		elif parent.velocity.x > 0:
			parent.velocity.x += -parent.AIR_ACCEL/5 #apply drag if not moving actively

func Landing():
	if state_includes([states.AIR, states.NAIR, states.UAIR, states.BAIR, states.FAIR, states.DAIR]):
		if parent.GroundL.is_colliding() and parent.velocity.y > 0:
			var collider = parent.GroundL.get_collider()
			parent.frame = 0
			if parent.velocity.y > 0:
				parent.velocity.y = 0
			parent.fastfall = false
			return true
		elif parent.GroundR.is_colliding() and parent.velocity.y > 0:
			var collider2 = parent.GroundR.get_collider()
			parent.frame = 0
			if parent.velocity.y > 0:
				parent.velocity.y = 0
			parent.fastfall = false
			return true

func Falling():
	if state_includes([states.STAND, states.DASH, states.MOONWALK, states.RUN, states.CROUCH, states.WALK, states.LANDING]):
		if not parent.GroundL.is_colliding() and not parent.GroundR.is_colliding():
			return true

func Ledge():
	if state_includes([states.AIR, states.LANDING]):
		if (parent.Ledge_Grab_F.is_colliding()):
			var collider = parent.Ledge_Grab_F.get_collider()

			if collider.get_node('Label').text == 'Ledge_L' and !Input.get_action_strength("down_%s" % id) > 0.6 and parent.regrab == 0 && !collider.is_grabbed:
				if state_includes([states.AIR]):
					if parent.velocity.y < 0:
						return false
				parent.frame = 0
				parent.velocity.x = 0
				parent.velocity.y = 0
				self.parent.position.x = collider.position.x - 20
				self.parent.position.y = collider.position.y + 20
				parent.turn(false)
				parent.reset_Jumps()
				parent.fastfall = false
				collider.is_grabbed = true
				parent.last_ledge = collider
				return true
			
			if collider.get_node('Label').text == 'Ledge_R' and !Input.get_action_strength("down_%s" % id) > 0.6 and parent.regrab == 0 && !collider.is_grabbed:
				if state_includes([states.AIR]):
					if parent.velocity.y < 0:
						return false
				parent.frame = 0
				parent.velocity.x = 0
				parent.velocity.y = 0
				self.parent.position.x = collider.position.x + 20
				self.parent.position.y = collider.position.y + 20
				parent.turn(true)
				parent.reset_Jumps()
				parent.fastfall = false
				collider.is_grabbed = true
				parent.last_ledge = collider
				return true
				
		if (parent.Ledge_Grab_B.is_colliding()):
			var collider = parent.Ledge_Grab_B.get_collider()
			if collider.get_node('Label').text == 'Ledge_L' and !Input.get_action_strength("down_%s" % id) > 0.6 and parent.regrab == 0 && !collider.is_grabbed:
				if state_includes([states.AIR]):
					if parent.velocity.y < 0:
						return false
				parent.frame = 0
				parent.velocity.x = 0
				parent.velocity.y = 0
				self.parent.position.x = collider.position.x - 20
				self.parent.position.y = collider.position.y + 20
				parent.turn(false)
				parent.reset_Jumps()
				parent.fastfall = false
				collider.is_grabbed = true
				parent.last_ledge = collider
				return true
				
			if collider.get_node('Label').text == 'Ledge_R' and !Input.get_action_strength("down_%s" % id) > 0.6 and parent.regrab == 0 && !collider.is_grabbed:
				if state_includes([states.AIR]):
					if parent.velocity.y < 0:
						return false
				parent.frame = 0
				parent.velocity.x = 0
				parent.velocity.y = 0
				self.parent.position.x = collider.position.x + 20
				self.parent.position.y = collider.position.y + 20
				parent.turn(true)
				parent.reset_Jumps()
				parent.fastfall = false
				collider.is_grabbed = true
				parent.last_ledge = collider
				return true

var kbx
var kby
var hd
var vd
var pos

func hitfreeze(duration, knockback):
	pos = parent.get_position()
	parent.freezeframes = duration
	kbx = knockback[0]
	kby = knockback[1]
	hd = knockback[2]
	vd = knockback[3]
