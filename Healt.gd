
extends Area2D

var taken=false

var player = null
var playerDT = null

var tipo = "healt"
var value = 20

func _on_body_enter( body ):
	if playerDT.healt<100:
		playerDT.incHealt(value)
		playerDT.pedras_usadas += 1
		playerDT.itens_coletados.push_back(get_name())
		#get_parent().remove_child(self)
		queue_free()

func _ready():
	player = get_node("/root/stage/Player")
	playerDT = get_node("/root/playerdata")


