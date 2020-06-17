extends Camera

# Node path of the object to follow
export (NodePath) var FOLLOW_PATH = null
# x distance from the object
export var TARGET_DISTANCE = 5.0
# y distance from the object
export var TARGET_HEIGHT = 4.0

#Global variables	
var followThis = null


# Called when the node enters the scene tree for the first time.
func _ready():
	followThis = get_node(FOLLOW_PATH)
	set_physics_process(true)
	set_as_toplevel(true)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var targetPos = followThis.get_translation()
#	var targetRot = followThis.get_rotation()
	
	var cameraPos = targetPos + Vector3(TARGET_DISTANCE,TARGET_HEIGHT,0)
#	var cameraRot = Vector3(0,targetRot.y,0)
	
	set_translation(cameraPos)
#	set_rotation(cameraRot)
	look_at(targetPos,Vector3(0,1,0))
	
