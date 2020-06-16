extends KinematicBody

var speed = 200
var direction = Vector3()

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
	if(Input.is_action_pressed("Right")):
		direction.z -= 1
	direction = direction.normalized()
	direction *= speed
	move_and_slide(direction,Vector3(0,3,0))
