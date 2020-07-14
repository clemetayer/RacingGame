extends RigidBody

## General car settings
# Speed of the car (normal speed)
export var SPEED = 50
# Rotation speed when turning
export var ROT_SPEED = PI/96
## Levitation
# Average levitation height
export var LEVITATION_HEIGHT = 3
# Levitation attenuation
export var LEVITATION_ATTENUATION = 1
## Tilts
# Maximum rotation tilt for turning left or right
export var MAX_ROT_TILT = PI/12
# Tilt speed for turning left or right
export var TILT_SPEED = PI/96

# Car movement vector (linear forces)
var movement = Vector3()
# Car rotation force
var torque = Vector3()
# Rotation of the car (in radians) in the world basis
var rot = Vector3()
# Epsilon for all rotations
var epsilon = PI/100 # ~= 0 degrees : to avoid very small rotations making the car look blurry around 0 degrees

# Called when the node enters the scene tree for the first time.
func _ready():
	movement = Vector3(0,0,0)
	rot = Vector3(0,0,0)

func _process(delta):
	get_node("UI/Speedometer").changeSpeed(get_linear_velocity().length())

func _integrate_forces(state):
	movement = Vector3(0,0,0)
	set_rotation(rot)
	inputManagement()
	
	add_force(computeFloorForceFront("FrontRayCast"), Vector3(-1,0,0))
	add_force(computeFloorForceFront("LeftRayCast"), Vector3(1,0,1))
	add_force(computeFloorForceFront("RightRayCast"), Vector3(1,0,-1))
	
	add_force(Vector3(movement.x * SPEED, 0, movement.z * SPEED), Vector3(0,0,0))

func inputManagement():
	var theta = fmod(rot.y, 2*PI)
	if(Input.is_action_pressed("Forward")):
		get_node("backCarParticles").emitting = true
		movement.x = -cos(theta)
		movement.z = sin(theta)
	elif(Input.is_action_pressed("Backward")):
		get_node("backCarParticles").emitting = true
		movement.x = cos(theta)
		movement.z = -sin(theta)
	if(Input.is_action_pressed("Left")):
		get_node("backCarParticles").emitting = true
		rot.x += computeTiltRotation(-1)
		rot.y += ROT_SPEED
		movement.z = 1
	elif(Input.is_action_pressed("Right")):
		get_node("backCarParticles").emitting = true
		rot.x += computeTiltRotation(1)
		rot.y -= ROT_SPEED
		movement.z = -1
	else: # center
		rot.x += computeTiltRotation(0)
		if(not(Input.is_action_pressed("Forward") or Input.is_action_pressed("Backward"))): # No directional key pressed
			get_node("backCarParticles").emitting = false
	if(Input.is_action_pressed("Drift")):
		get_node("UI/MouseGauge").computeDriftAmount()
	elif(Input.is_action_just_released("Drift")):
		get_node("UI/MouseGauge").hideGauge()

# computes the floor effect on the front
func computeFloorForceFront(raycastName):
	# Test to see if the car is falling
	if(get_node(raycastName).get_collider() == null): # Not on floor (i.e falling)
		return Vector3(0,0,0)

	# Raycast data
	var maxHeight = - get_node(raycastName).get_cast_to().y
	var floorDistance = get_translation().y - get_node(raycastName).get_collision_point().y
	
	# Force computation
	var force = Vector3(0,0,0)
	force.y = ((LEVITATION_HEIGHT/floorDistance) * weight / 3) - get_linear_velocity().y * mass * LEVITATION_ATTENUATION
	return force

# computes the rotation of a tilt with direction (-1 for left, 0 for center, 1 for right)
func computeTiltRotation(dir):
	if(dir == -1): # left
		if(rot.x > MAX_ROT_TILT):
			return 0
		else:
			return TILT_SPEED
	elif(dir == 1): # right
		if(rot.x < -MAX_ROT_TILT):
			return 0
		else:
			return -TILT_SPEED
	else: # center
		if(rot.x > epsilon):
			return -TILT_SPEED
		elif(rot.x < -epsilon):
			return TILT_SPEED
		else:
			return 0
