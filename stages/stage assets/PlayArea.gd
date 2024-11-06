extends Area2D

# Assuming the character node name is "Character"
onready var character = get_parent().get_node("Knight")
onready var character2 = get_parent().get_node("Knight2")

func _ready():
	# Connect the area_exited signal
	connect("body_exited", self, "_on_PlayArea_body_exited")

# Signal handler for area_exited
func _on_PlayArea_body_exited(exiting_area):
	print('exited PlayArea')
	# Check if the exiting area is the character
	if exiting_area == character:
		# Reset character position to (0, 0)
		character.position.x = 0
		character.position.y = 0
		character.reset()
	elif exiting_area == character2:
		# Reset character position to (0, 0)
		character2.position.x = 0
		character2.position.y = 0
		character2.reset()
