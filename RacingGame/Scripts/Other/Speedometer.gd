extends Control

func changeSpeed(speed):
	var firstBBCode = "[fill][center][color=yellow]"
	var lastBBCode = "[/color][/center][/fill]"
	var text = str(firstBBCode, abs(int(speed)), lastBBCode)
	get_node("RichTextLabel").set_bbcode(text)
