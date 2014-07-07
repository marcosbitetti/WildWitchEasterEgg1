
extends Area2D

const VEL = 50

var span_pos = null
var xmin = 0
var xmax = 1024
var dir = -1
var hp = 500

var body = null
var playerDT = null
var player = null
var timer = null

func incHealt(v):
	hp += v
	if hp<0:
		hp = 0
		end()

func end():
	set_process( false )
	get_parent().remove_child( self )

# causa 25 de dano por hit
func porrada():
	playerDT.incHealt(-25)

func _process(delta):
	if not playerDT.game_running:
		return
		
	var pos = get_pos()
	
	pos.x += VEL*delta*dir
	
	if pos.x < xmin :
		dir = 1
		body.set_scale(Vector2(-1,1))
	elif pos.x > xmax :
		dir = -1
		body.set_scale(Vector2(1,1))
	
	set_pos( pos )
	
	if hp<1:
		end()


func _on_body_enter( body ):
	# pega o valor apartir do objeto basico
	var isGhost = body.get("ghost_mode")
	if isGhost != null:
		if not isGhost: # get_node("/root/stage/Player").ghost_mode:
			porrada()
			timer.start()

func _on_body_exit( body ):
	timer.stop()

func _on_Timer_timeout():
	porrada()

func _ready():
	# limites
	span_pos = get_pos()
	xmin = span_pos.x - 256
	xmax = span_pos.x + 256
	
	player = get_node("/root/stage/Player")
	playerDT = get_node("/root/playerdata")
	body = get_node("Sprite")
	timer = get_node("Timer")
	
	set_process( true )





