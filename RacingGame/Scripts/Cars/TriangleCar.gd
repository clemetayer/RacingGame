extends KinematicBody

# Max normal speed (by pressing forward only)
export var SPEED = 1000
# Force that makes the car levitate
export var FLOOR_PUSH_FORCE = 20
# Maximum rotation tilt for turning left or right
export var MAX_ROT_TILT = 15
# Tilt speed for turning left or right
export var TILT_SPEED = 0.05
# Rotation sensitivity when drifting
export var DRIFT_SENSITIVITY = 0.15

var direction = Vector3()
var gravity = -10
var velocity = Vector3()
var baseMousePos = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	direction = Vector3(0,0,0)
	
	if(Input.is_action_pressed("Forward")):
		direction.x -= 1
	if(Input.is_action_pressed("Backward")):
		direction.x += 1
	if(Input.is_action_pressed("Left")):
		direction.z += 1
		rotate_x(computeTiltRotation(-1))
	elif(Input.is_action_pressed("Right")):
		direction.z -= 1
		rotate_x(computeTiltRotation(1))
	else: # center
		rotate_x(computeTiltRotation(0))
	if(Input.is_action_pressed("Drift")):
		rotate_y(- (get_node("UI/MouseGauge").computeDriftAmount() * DRIFT_SENSITIVITY)) 
#		print("drifting : ", get_node("UI/MouseGauge").computeDriftAmount())
	elif(Input.is_action_just_released("Drift")):
		get_node("UI/MouseGauge").hideGauge()

	direction = direction.normalized()
	direction *= SPEED * delta
	
	velocity.y += gravity * delta
	velocity.x = direction.x
	velocity.z = direction.z
	
	var floorPos = get_node("RayCast").get_collision_point()
	var posDiff = get_translation().y - floorPos.y
	velocity.y += (1/(posDiff + 1)) * FLOOR_PUSH_FORCE * delta
	
	velocity = move_and_slide(velocity,Vector3(0,3,0))

# computes the direction rotation of a tilt with direction (-1 for left, 0 for center, 1 for right)
func computeTiltRotation(direction):
	var cur_angle = get_rotation_degrees()
	var epsilon = 3 # ~= 0 degrees : to avoid very small rotations making the car look blurry around 0 degrees
	if(direction == -1): # left
		if(cur_angle.x > MAX_ROT_TILT):
			return 0
		else:
			return TILT_SPEED
	elif(direction == 1): # right
		if(cur_angle.x < -MAX_ROT_TILT):
			return 0
		else:
			return -TILT_SPEED
	else: # center
		if(cur_angle.x > epsilon):
			return -TILT_SPEED
		elif(cur_angle.x < -epsilon):
			return TILT_SPEED
		else:
			return 0
