extends Camera

# Parameters variables
export (NodePath) var FOLLOW_PATH = get_parent().get_node("TriangleCar")
export var TARGET_DISTANCE = 3.0
export var TARGET_HEIGHt = 2.0

#Global variables	
var followThis = null


# Called when the node enters the scene tree for the first time.
func _ready():
	followThis = get_node(FOLLOW_PATH)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
