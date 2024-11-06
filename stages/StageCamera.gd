extends Camera2D

onready var p1 = get_parent().get_node("Knight")
onready var p2 = get_parent().get_node("Knight2")

# Define the minimum and maximum zoom levels
const MIN_ZOOM = Vector2(0.3, 0.3)  # Adjust as needed
const MAX_ZOOM = Vector2(1.0, 1.0)  # Adjust as needed
const ZOOM_SCALING_FACTOR = 0.001  # Adjust to control how zoom changes with distance

# Define the speed of interpolation for position and zoom
const POSITION_LERP_SPEED = 0.1  # Higher value makes it follow faster
const ZOOM_LERP_SPEED = 0.1      # Higher value makes it zoom faster

func _physics_process(delta):
	# Target position: midpoint between the two players
	var target_position = (p1.position + p2.position) * 0.5
	
	# Smoothly interpolate the camera's position toward the target
	self.position = self.position.linear_interpolate(target_position, POSITION_LERP_SPEED)
	
	# Calculate the distance between players for dynamic zoom
	var distance = p1.position.distance_to(p2.position)
	
	# Target zoom based on distance
	var target_zoom_factor = distance * ZOOM_SCALING_FACTOR
	var target_zoom = Vector2(target_zoom_factor, target_zoom_factor)
	
	# Clamp the target zoom
	target_zoom.x = clamp(target_zoom.x, MIN_ZOOM.x, MAX_ZOOM.x)
	target_zoom.y = clamp(target_zoom.y, MIN_ZOOM.y, MAX_ZOOM.y)
	
	# Smoothly interpolate the camera's zoom toward the target zoom
	self.zoom = self.zoom.linear_interpolate(target_zoom, ZOOM_LERP_SPEED)
