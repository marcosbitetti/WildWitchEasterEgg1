
extends Node2D

var alpha = 1.0

func _ready():
	# Initalization here
	pass

func _on_Timer_timeout():
	alpha -= alpha*.2
	set_opacity(alpha)
	print(alpha)
	if alpha<0.3 :
		get_node("Timer").stop()
		get_parent().remove_child(self)
	
