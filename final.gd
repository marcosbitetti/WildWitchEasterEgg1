
extends Node2D

var tempo = 0
var info = null

func _process(delta):
	tempo += delta
	#info.set_text(str(tempo))
	
	if tempo>115:
		#get_node("/root/playerdata").swap_scene("res://menu.scn")
		get_node("/root/playerdata").swap_scene("res://Creditos.scn")

func _ready():
	#info = get_node("info")
	set_process(true)


