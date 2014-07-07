
extends RigidBody2D

export(float) var initialDelay = 1.0
export(float) var trigger_time = 2.0
export(int) var jump_force = 150

var iniTime = 0
var acTime = 0
var playerDT = null
var player = null

func end():
	set_process( false )
	queue_free()
	

func _on_body_enter( body ):
	var isGhost = body.get("ghost_mode")
	if isGhost != null:
		if not isGhost:
			playerDT.incHealt(-45)
			playerDT.list_2_kill(-35,self, get_children()[0].get_global_pos(), 64,64)
			#end()


func _process(delta):
	if not playerDT.game_running:
		return
	
	var v = get_linear_velocity()
	
	if iniTime>initialDelay:
	
		acTime += delta
		
		if acTime>trigger_time:
			acTime = 0
			set_linear_velocity(Vector2(0,-jump_force))
	else:
		iniTime += delta

func _ready():
	player = get_parent().get_parent().get_node("Player")
	playerDT = get_node("/root/playerdata")
	set_process(true)
	

