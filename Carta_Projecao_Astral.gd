
extends Area2D

var taken=false

var player = null

var tipo = "carta"
var sub_tipo = "projecao_astral"

func _on_body_enter( body ):
	if (not taken ):
		taken=true
		player.adicionarCarta(sub_tipo,get_name())
		
		queue_free()

func _ready():
	# Initalization here
	player = get_parent().get_parent().get_node("Player")
	