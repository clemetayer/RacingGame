extends Control

var baseMousePos = null
var startFrame = null
var endFrame = null
var lengthFrame = null

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()

# ===== for debug =====
#func _process(delta):
#	if(Input.is_action_pressed("Drift")):
#		print("drifting : ", computeDriftAmount())
#	elif(Input.is_action_just_released("Drift")):
#		hideGauge()

func computeDriftAmount():
	if(baseMousePos == null):
		show()
		baseMousePos = get_viewport().get_mouse_position()
		get_node("Gauge").position = baseMousePos
		get_node("Cursor").position = baseMousePos
		startFrame = get_node("Gauge").get_rect().position.x + baseMousePos.x
		endFrame = get_node("Gauge").get_rect().end.x + baseMousePos.x
		lengthFrame = endFrame - startFrame
	var mousePos = get_viewport().get_mouse_position().x
	if(mousePos <= startFrame): # right limit
		get_node("Cursor").position.x = startFrame
		return -0.5 # max drift to the left
	elif(mousePos >= endFrame): # left limit
		get_node("Cursor").position.x = endFrame
		return 0.5 # max drift to the right
	else:
		get_node("Cursor").position.x = mousePos
		return (mousePos - baseMousePos.x)/lengthFrame

func hideGauge():
	baseMousePos = null
	hide()
