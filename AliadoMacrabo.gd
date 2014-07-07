
extends Area2D

var player = null
var playerDT = null
const T_DIST = 90
const VANG = 225.0 * (3.1415926515/180.0)
var vec = Vector2(1.0,0.0)
var tp = null
var ang = 0

var inimigos = null


func _process(delta):
	ang += VANG * delta
	var r = vec.rotated( ang )
	tp += (player.get_pos() - tp) * delta * 0.7
	var p = tp
	p.x += r.x*T_DIST
	p.y += r.y*T_DIST
	set_pos( p )
	
	var x0 = p.x-32
	var x1 = p.x+32
	var y0 = p.y-32
	var y1 = p.y+32
	for inimigo in inimigos.get_children():
		var pi = inimigo.get_pos()
		if pi.x>x0 and pi.x<x1:
			if pi.y>y0 and pi.y<y1:
				playerDT.inimigos_mortos.push_back(inimigo.span_pos)
				playerDT.kills += 1
				player.showBlood(pi)
				#inimigo.queue_free()
				inimigo.incHealt(-20) # 20 de dano
				queue_free()
	
	
func _ready():
	player = get_parent().get_parent().get_node("Player")
	playerDT = get_node("/root/playerdata")
	inimigos = get_parent().get_parent().get_node("inimigos_nd")
	
	tp = player.get_pos()
	set_process(true)


