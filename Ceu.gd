
extends Node2D

var olhos = null
var emissor = null
var cibele = null
var anim = null
var aTime = 0
var dTime1 = 2

func _process(delta):
	aTime += delta
	
	#animacoes
	if aTime >= dTime1:
		if olhos.is_visible():
			olhos.hide()
			dTime1 = aTime + rand_range(1,4)
		else:
			olhos.show()
			dTime1 = aTime + 0.3
	
	# Convorme issue #327 este trecho adapta a escala
	# do emissor para a escala do objeto pai
	emissor.set_param( Particles2D.PARAM_INITIAL_SIZE, cibele.get_scale().x)
	emissor.set_param( Particles2D.PARAM_GRAVITY_STRENGTH, 30*cibele.get_scale().x)
	emissor.set_param( Particles2D.PARAM_LINEAR_VELOCITY, 300*cibele.get_scale().x)
	
	
	var move_left = Input.is_action_pressed("move_left")
	var barra_espaco = Input.is_action_pressed("barra_espaco")
	var enter = Input.is_action_pressed("magic_act")
	
	print( anim.get_current_animation_pos() )
	
	
func _ready():
	olhos = get_node("camera/Cibele/fechado")
	emissor = get_node("camera/Cibele/emi")
	cibele = get_node("camera/Cibele")
	anim = get_node("AnimationPlayer")
	
	get_node("anim").play("Intro",1,12,false)

	set_process(true)


