extends RigidBody

## NOTE : this script is HEAVILY inspired from a Unity tutorial ported to Godot :
## https://www.youtube.com/playlist?list=PLX2vGYjWbI0SvPiKiMOcj_z9zCG7V9lkp

## This script handles all of the physics behaviors for the player's ship. The primary functions
## are handling the hovering and thrust calculations.

## Drive settings
export var DRIVE_FORCE = 17.0 # The force that the engine generates
export var THRUSTER_FORCE = 2.0 # Ship's thruster force (forward/backward)
export var RUDDER_FORCE = PI/100 # Ship's rudder force (Left/Right)
export var DRIFT_AMOUNT = 1.0 # How much the car will drift when turning
export var SLOWING_VEL_FACTOR = 0.99 # The percentage of velocity the ship maintains when not thrusting (e.g., a value of .99 means the ship loses 1% velocity when not thrusting)
export var BRAKING_VEL_FACTOR = 0.95 # The percentage of velocty the ship maintains when braking
export var ANGLE_OF_ROLL = 30.0 # The angle that the ship "banks" into a turn
export var BANKING_SPEED = 5.0 # How fast the ship "banks" into a turn

## Hover settings
export var HOVER_HEIGHT = 3.0 # The height the ship maintains when hovering
export var MAX_GROUND_DIST = 10.0 # The distance the ship can be above the ground before it is "falling"
export var HOVER_FORCE = 300.0 # The force of the ship's hovering
export var GROUND_ROTATION_SMOOTHENING = 0.25 # Rotation speed to follow the ground 

## Physics settings
export var TERMINAL_VELOCITY = 500.0 # The max speed the ship can go
export var HOVER_GRAVITY = 20.0 # The gravity applied to the ship while it is on the ground
export var FALL_GRAVITY = 80.0 # The gravity applied to the ship while it is falling

# Vehicle basis
var rot = fmod(rotation.y, 2*PI)
var aim = self.get_global_transform().basis
var forward = aim.x
var backward = -aim.x
var down = -aim.y
var up = aim.y
var left = aim.x
var right = -aim.x

# Inputs
var rudder = 0
var thruster = 0
var isBraking = false

# Global variables
var speed = 0 # The current forward speed of the ship (set initially to 0 to avoid an error at start)
var shipBody # A reference to the ship's body, this is for cosmetics (for banking of ship)
var hoverPID # A PID controller to smooth the ship's hovering
var drag # The air resistance the ship recieves in the forward direction
var isOnGround # A flag determining if the ship is currently on the ground
var sidewaysSpeed = 0.001 # To avoid it being = 0 (and making a division by 0)
var sideFriction = 0.001 # idem

# Called when the node enters the scene tree for the first time.
func _ready():
	# Initialisation of variables
	shipBody = get_node("TriangleCar")
	get_node("RayCast").set_cast_to(Vector3(0,-1,0) * MAX_GROUND_DIST)
	hoverPID = get_node("PIDController")
	sidewaysSpeed = Vector3(0,0,0)
	sideFriction = Vector3(0,0,0)
	
	# Calculate the ship's drag value
	drag = DRIVE_FORCE / TERMINAL_VELOCITY


func _process(delta):
	
	rot = fmod(rotation.y, 2*PI)
	get_global_transform().basis.rotated(Vector3(0,1,0),rot)
	aim = get_global_transform().basis
	forward = aim.x
	backward = -aim.x
	down = -aim.y
	up = aim.y
	left = aim.z
	right = -aim.z
	
	# Methods for input detection
	inputManagement()
	
	# Calculate the current speed by using the dot product. This tells us
	# how much of the ship's velocity is in the "forward" direction 
	speed = get_linear_velocity().dot(forward)
	
	get_node("UI/Speedometer").changeSpeed(speed)
	
	# Calculate the current sideways speed by using the dot product. 
	# This tells us how much of the ship's velocity is in the "right" or "left" direction
	sidewaysSpeed = get_linear_velocity().dot(right)
	
	# Calculate the desired amount of friction to apply to the side of the vehicle.
	# This is what keeps the ship from drifting into the walls during turns. 
	# If you want to add drifting to the game, divide delta by some amount
	sideFriction = -right * (sidewaysSpeed/delta)
	
	if(isOnGround):
		# Calculate the angle we want the ship's body to bank into a turn based on the current rudder.
		# It is worth noting that these next few steps are completetly optional and are cosmetic.
		# It just feels so darn cool
		var angle = ANGLE_OF_ROLL * -rudder;
		# Calculate the rotation needed for this new angle
		var bodyRotation = rotation * Vector3(-1/get_rotation().x,0,0) * angle # Finally, apply this angle to the ship's body
		get_node("TriangleCar").rotation = shipBody.rotation.linear_interpolate(bodyRotation, delta * BANKING_SPEED)
	
func _integrate_forces(state):
	CalculateHover()
	CalculatePropulsion()

func inputManagement():
	if(Input.is_action_pressed("Left")):
		rudder = RUDDER_FORCE
	elif(Input.is_action_pressed("Right")):
		rudder = -RUDDER_FORCE
	else:
		rudder = 0
	if(Input.is_action_pressed("Forward")):
		thruster = -THRUSTER_FORCE
		isBraking = false
	elif(Input.is_action_pressed("Backward")):
		isBraking = true
		thruster = THRUSTER_FORCE
	else:
		isBraking = false
		thruster = 0

func CalculateHover():
	var raycast = get_node("RayCast")
	var groundNormal
	var gravity
	isOnGround = raycast.is_colliding()
	# If the ship is on the ground...
	if(isOnGround):
		# ...determine how high off the ground it is...
		var height = raycast.get_collision_point().distance_to(get_translation())
		# ...save the normal of the ground...
		groundNormal = raycast.get_collision_normal()
		# ...use the PID controller to determine the amount of hover force needed...
		var forcePercent = hoverPID.seek(HOVER_HEIGHT,height)
		# ...calculcate the total amount of hover force based on normal (or "up") of the ground...
		var force = groundNormal * HOVER_FORCE * forcePercent
		# ...calculate the force and direction of gravity to adhere the ship to the track (which is not always straight down in the world)...
		gravity = -groundNormal * HOVER_GRAVITY * height
		# ...and finally apply the hover and gravity forces
		add_force(force, Vector3(0,0,0))
		add_force(gravity, Vector3(0,0,0))
		# Calculate the amount of pitch and roll the ship needs to match its orientation with that of the ground.
		# This is done by creating a projection and then calculating the rotation needed to face that projection
		var projection = get_node("RayCastMinusZ").get_collision_point() - get_node("RayCast").get_collision_point()
		var lookPoint = transform.origin + projection
		DebugDraw.draw_line_3d(get_node("RayCast").get_collision_point(), projection, Color(1,0,0))
		look_at(lookPoint, get_node("RayCast").get_collision_normal())
	# ...Otherwise...
	else:
		#  ...use Up to represent the "ground normal". This will cause our ship to self-right itself in a case where it flips over
		groundNormal = up
		# Calculate and apply the stronger falling gravity straight down on the ship
		gravity = -groundNormal * FALL_GRAVITY
		add_force(gravity,Vector3(0,0,0))

func CalculatePropulsion():
	# Apply the torque to the ship's Y axis
	rotate(up, rudder)
#	add_torque(Vector3(0,1,0) * rotationTorque)
	# Finally, apply the sideways friction
	add_force(sideFriction/DRIFT_AMOUNT,Vector3(0,0,0))
	if(thruster <= 0):
		linear_velocity *= SLOWING_VEL_FACTOR 
	# Braking or driving requires being on the ground, so if the ship isn't on the ground, exit this method
	if(not isOnGround):
		return
	# If the ship is braking, apply the braking velocity reduction
	if(isBraking):
		linear_velocity *= BRAKING_VEL_FACTOR 
	# Calculate and apply the amount of propulsion force by multiplying the drive force by 
	# the amount of applied thruster and subtracting the drag amount
	var propulsion = DRIVE_FORCE * thruster - drag * clamp(speed, 0, TERMINAL_VELOCITY)
	add_force(forward * propulsion, Vector3(0,0,0))
