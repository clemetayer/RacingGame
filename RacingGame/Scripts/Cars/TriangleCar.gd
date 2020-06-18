extends KinematicBody

# Max normal speed (by pressing forward only)
export var SPEED = 1000
# Force that makes the car levitate
export var FLOOR_PUSH_FORCE = 20
# Maximum rotation tilt for turning left or right
export var MAX_ROT_TILT = PI/12
# Tilt speed for turning left or right
export var TILT_SPEED = PI/96
# Rotation sensitivity when drifting
export var DRIFT_SENSITIVITY = PI/12

var direction = Vector3()
var rot = Vector3()
var gravity = -10
var velocity = Vector3()
var baseMousePos = null

# Called when the node enters the scene tree for the first time.
func _ready():
	rot = Vector3(0,0,0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	direction = Vector3(0,0,0)
	if(Input.is_action_pressed("Forward")):
		direction.x += cos(rot.y + PI)
		direction.z += sin(rot.y)
	if(Input.is_action_pressed("Backward")):
		direction.x += cos(rot.y)
		direction.z += sin(rot.y + PI)
	if(Input.is_action_pressed("Left")):
		direction.x += sin(rot.y)
		direction.z += cos(rot.y)
		rot.x += computeTiltRotation(-1)
	elif(Input.is_action_pressed("Right")):
		direction.x += sin(rot.y + PI)
		direction.z += cos(rot.y + PI)
		rot.x += computeTiltRotation(1)
	else: # center
		rot.x += computeTiltRotation(0)
	if(Input.is_action_pressed("Drift")):
		rot.y += - (get_node("UI/MouseGauge").computeDriftAmount() * DRIFT_SENSITIVITY)
#		print("drifting : ", get_node("UI/MouseGauge").computeDriftAmount())
	elif(Input.is_action_just_released("Drift")):
		get_node("UI/MouseGauge").hideGauge()

	direction = direction.normalized()
	direction *= SPEED * delta
	
	rot.x = fmod(rot.x,2*PI)
	rot.y = fmod(rot.y,2*PI)
	rot.z = fmod(rot.z,2*PI)
	
	set_rotation(rot)
	
	velocity.y += gravity * delta
	velocity.x = direction.x
	velocity.z = direction.z
	
	var floorPos = get_node("RayCast").get_collision_point()
	var posDiff = get_translation().y - floorPos.y
	velocity.y += (1/(posDiff + 1)) * FLOOR_PUSH_FORCE * delta
	
	velocity = move_and_slide(velocity,Vector3(0,3,0))

# computes the direction rotation of a tilt with direction (-1 for left, 0 for center, 1 for right)
func computeTiltRotation(direction):
	var epsilon = 3 # ~= 0 degrees : to avoid very small rotations making the car look blurry around 0 degrees
	if(direction == -1): # left
		if(rot.x > MAX_ROT_TILT):
			return 0
		else:
			return TILT_SPEED
	elif(direction == 1): # right
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
