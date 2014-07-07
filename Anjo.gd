
extends Area2D

var playerDT = null
var player = null
var active = false
func _on_body_enter( body ):
	if not active:
		active = true
		get_node("balao").show()
		get_node("Timer").start()

func _on_Timer_timeout():
	playerDT.incHealt(100)
	playerDT.incMana(100)
	#get_parent().get_parent().get_node("finaltime").start()
	get_node("AnimationPlayer").play("magia")
	get_node("balao").hide()
	playerDT.fly_mode = 1
	get_parent().get_parent().get_node("Lava").init()

func _ready():
	player = get_parent().get_parent().get_node("Player")
	playerDT = get_node("/root/playerdata")





