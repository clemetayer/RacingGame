extends Spatial

## NOTE : this script is HEAVILY inspired from a Unity tutorial ported to Godot :
## https://www.youtube.com/playlist?list=PLX2vGYjWbI0SvPiKiMOcj_z9zCG7V9lkp

# Our PID coefficients for tuning the controller
var pCoeff = 0.8
var iCoeff = 0.0002
var dCoeff = 0.2
var minimum = -1
var maximum = 1

# Variables to store values between calculations
var integral = 0.0
var lastProportional = 0.0

var deltaTime = 0.0001

func _process(delta):
	deltaTime = delta
# We pass in the value we want and the value we currently have, the code
# returns a number that moves us towards our goal
func seek(seekValue, currentValue):
	var proportional = seekValue - currentValue

	var derivative = (proportional - lastProportional) / deltaTime
	integral += proportional * deltaTime
	lastProportional = proportional

	# This is the actual PID formula. This gives us the value that is returned
	var value = pCoeff * proportional + iCoeff * integral + dCoeff * derivative
	value = clamp(value, minimum, maximum)

	return value
