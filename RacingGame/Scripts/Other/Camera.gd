extends Camera

# Node path of the object to follow
export (NodePath) var FOLLOW_PATH = null
# x distance from the object
export var TARGET_DISTANCE = 5.0
# y distance from the object
export var TARGET_HEIGHT = 4.0

#Global variables	
var followThis = null
var cameraType = 1


# Called when the node enters the scene tree for the first time.
func _ready():
	followThis = get_node(FOLLOW_PATH)
	set_physics_process(true)
	set_as_toplevel(true)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	var targetPos = followThis.get_translation()
	
	var targetRot = followThis.get("rot")

	var cameraPos = targetPos + Vector3(cos(targetRot)*TARGET_DISTANCE, TARGET_HEIGHT, sin(targetRot + PI)*TARGET_DISTANCE)

	set_translation(cameraPos)
	look_at(targetPos,Vector3(0,1,0))
