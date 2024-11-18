extends Node

func hitstun(mod, duration):
	Engine.time_scale = mod/100
	print(str(mod))
	yield(get_tree().create_timer(duration * Engine.time_scale), "timeout") # so timer does not depend on in-engine speed
	Engine.time_scale = 1
