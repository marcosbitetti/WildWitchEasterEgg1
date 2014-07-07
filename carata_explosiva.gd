
extends Area2D

# member variables here, example:
# var a=2
# var b="textvar"


var taken=false

var player = null

var tipo = "carta"
var sub_tipo = "explosiva"

func _on_body_enter( body ):
	if (not taken ): #and body extends player):
		taken=true
		#get_node("anim").play("taken")
		#print("peguei a carta")
		#print( get_node("/stage/Player") )
		
		#player.notification(1)
		
		player.adicionarCarta(sub_tipo,get_name())
		queue_free()
		

func _ready():
	# Initalization here
	player = get_parent().get_parent().get_node("Player")
	

