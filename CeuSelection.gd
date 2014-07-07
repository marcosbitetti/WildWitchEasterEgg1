
extends Node

var anim = null
var playerDT = null
var timmer = 0 # delay entre teclas para evitar acidentes

func _process(delta):
	var move_left = Input.is_action_pressed("move_left")
	var barra_espaco = Input.is_action_pressed("barra_espaco")
	var enter = Input.is_action_pressed("magic_act")
	
	timmer += delta
	
	if timmer>1.0 and anim.get_current_animation_pos()<anim.get_current_animation_length() :
		if move_left or barra_espaco or enter:
			anim.seek( anim.get_current_animation_length(), true )
			timmer = 0
			pass
	
	elif timmer > 1.0: #anim.get_current_animation_pos() >= anim.get_current_animation_length() :
		if move_left :
			anim.seek( 0, true )
			#anim.play("intro",0)
		
		if enter:
			get_node("/root/playerdata").swap_scene("res://main_ceu.scn")
			
		if barra_espaco:
			playerDT.healt = 1
			playerDT.game_running = true
			get_node("/root/playerdata").swap_scene("res://main.scn")
	
	
func _ready():
	anim = get_node("AnimationPlayer")
	playerDT = get_node("/root/playerdata")
	#if	playerDT.info == "cena2" :
	#	playerDT.info = ""
	#	anim.play("final")
	#else:
	#	anim.play("intro")
	anim.play("intro")
	
	if get_node("/root/playerdata").tocarMusica:
		if get_node("music"):
			get_node("music").play()
	
	set_process(true)

