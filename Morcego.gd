
extends Area2D

const VEL_VOO = 100

export(bool) var right2Left = true

var span_pos = null
var hp = 10
var VL = VEL_VOO

var playerDT = null
var player = null

func incHealt(v):
	hp += v
	if hp<0:
		hp = 0
		end()

func end():
	set_process( false )
	#get_parent().remove_child( self )
	queue_free()

func _process(delta):

	if hp<=0:
		end()
		return

	if not playerDT.game_running:
		return
		
	var pos = get_pos()
	
	pos.x -= VL*delta
	if right2Left:
		if (pos.x < -128.0):
			pos.x = span_pos.x
	else:
		if (pos.x > 2365.0):
			pos.x = span_pos.x
	
	set_pos( pos )
	
	if hp<1:
		end()


func _on_body_enter( body ):
	if not player.ghost_mode:
		if body.get_node("aliado") :
			print("me mataram")
		#playerDT.incHealt(-35)
		playerDT.list_2_kill(-35,self, get_children()[0].get_global_pos(), 64,64)
		#end()



func _ready():
	span_pos = get_pos()
	
	player = get_parent().get_parent().get_node("Player")
	playerDT = get_node("/root/playerdata")
	
	VL = VEL_VOO
	if not right2Left:
		VL = -VEL_VOO
		set_scale(Vector2(-1,1))
	
	set_process( true )


