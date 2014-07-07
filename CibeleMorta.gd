
extends Node2D

var olhos = null
var emissor = null
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
	emissor.set_param( Particles2D.PARAM_INITIAL_SIZE, get_scale().x)
	emissor.set_param( Particles2D.PARAM_GRAVITY_STRENGTH, 30*get_scale().x)
	emissor.set_param( Particles2D.PARAM_LINEAR_VELOCITY, 300*get_scale().x)
	
	
func _ready():
	olhos = get_node("fechado")
	emissor = get_node("emi")

	set_process(true)

