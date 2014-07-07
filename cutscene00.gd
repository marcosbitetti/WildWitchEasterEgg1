
extends Node

#const DEBUG = false
#var debug = null
var delay = 0

func _process(delta):
	#if DEBUG:
	#	var t = str(Performance.get_monitor(Performance.TIME_FPS))
	#	debug.set_text("FPS: " + t)
	
	delay += delta
	
	var barra_espaco = Input.is_action_pressed("barra_espaco")
	var enter = Input.is_action_pressed("magic_act")
	
	if enter and delay>0.15:
		delay = 0
		get_node("AnimationPlayer").play("intro01")
	
	if barra_espaco and delay>0.15:
		
		get_node("/root/playerdata").swap_scene("res://menu.scn")
	
	

func _ready():
	#debug = get_node("camera/debug")
	#if get_node("/root/playerdata").tocarMusica:
	if get_node("music"):
		get_node("music").play()
	
	set_process(true)
	

