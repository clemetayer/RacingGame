extends KinematicBody

# Max normal speed (by pressing forward only)
export var NORMAL_SPEED = 100
# Mass of the vehicle
export var MASS = 3
# Force that makes the car levitate
export var FLOOR_PUSH_FORCE = 20
# Amplitude of levitation cycle
export var LEVITATION_AMP = 1
# Maximum rotation tilt for turning left or right
export var MAX_ROT_TILT = PI/12
# Tilt speed for turning left or right
export var TILT_SPEED = PI/96
# Acceleration of the car
export var ACCELERATION = 25
# Rotation (for the car) sensitivity when drifting
export var DRIFT_SENSITIVITY = PI/12
# Rotation speed of the movement vector when drifting
export var DRIFT_SLIDE = 40

# Direction towards the car is supposed to go
var direction = Vector3()
# Kind of same as direction, but mixed with a speed vector + Inertia
var speedDir = Vector3()
# Real direction of the car + levitation
var velocity = Vector3()
# Rotation of the car (in radians) in the world basis
var rot = Vector3()
# Rotation of the movement vector (to get a sliding feeling)
var mvRot = Vector3()
# Epsilon for all rotations
var epsilon = PI/100 # ~= 0 degrees : to avoid very small rotations making the car look blurry around 0 degrees
# Gravity
var gravity = -10
# Position of the mouse when clicked
var baseMousePos = null

# Called when the node enters the scene tree for the first time.
func _ready():
	rot = Vector3(0,0,0)
	mvRot = Vector3(0,0,0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	computeMovementAngle()
	
	set_rotation(rot)
	
	inputManagement()
	
	direction = direction.normalized()
	direction *=  NORMAL_SPEED * delta
	
	computeSpeedDir()
	
	velocity.y += (gravity * MASS) * delta
	velocity.x = -speedDir.x # Actually don't know why i am forced to compute the opposite, but it works :/
	velocity.z = -speedDir.z 
	
	var floorPos = get_node("RayCast").get_collision_point()
	var posDiff = get_translation().y - floorPos.y
	velocity.y += (LEVITATION_AMP/posDiff) * (FLOOR_PUSH_FORCE * MASS) * delta
	
	velocity = move_and_slide(velocity,Vector3(0,1,0))

func inputManagement():
	direction = Vector3(0,0,0)
	if(Input.is_action_pressed("Forward")):
		direction.x += cos(mvRot.y + PI)
		direction.z += sin(mvRot.y)
	elif(Input.is_action_pressed("Backward")):
		direction.x += cos(mvRot.y)
		direction.z += sin(mvRot.y + PI)
	if(Input.is_action_pressed("Left")):
		direction.x += sin(mvRot.y)
		direction.z += cos(mvRot.y)
		rot.x += computeTiltRotation(-1)
	elif(Input.is_action_pressed("Right")):
		direction.x += sin(mvRot.y + PI)
		direction.z += cos(mvRot.y + PI)
		rot.x += computeTiltRotation(1)
	else: # center
		rot.x += computeTiltRotation(0)
		if(not(Input.is_action_pressed("Forward") or Input.is_action_pressed("Backward"))): # No directional key pressed
			direction = Vector3(0,0,0)
	if(Input.is_action_pressed("Drift")):
		rot.y += - (get_node("UI/MouseGauge").computeDriftAmount() * DRIFT_SENSITIVITY)
	elif(Input.is_action_just_released("Drift")):
		get_node("UI/MouseGauge").hideGauge()

func computeSpeedDir():
	var dist = speedDir - direction
	dist -= dist/ACCELERATION
	speedDir.x = dist.x
	speedDir.z = dist.z

# computes the direction the car will move
func computeMovementAngle():
	if(Input.is_action_pressed("Steer") or (abs(mvRot.y - rot.y) < epsilon)):
		mvRot.y = rot.y
	else:
		mvRot.y += (rot.y - mvRot.y)/DRIFT_SLIDE

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
