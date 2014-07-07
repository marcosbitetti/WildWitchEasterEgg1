
extends Node2D

var rad = 0
var hp = 100
var bar = null
var anim = null
var kabum = false
var sound = null
var playerDT = null
var player = null
const MRAD = 300
const MRAD2 = 600
const SQRAD = 300*300
const TRAD = 299
const TIMEDEC = 20 # porcentagem por segundo


func radialDestruction():
	var tileset = get_parent().get_node("TileMap")
	var cen = get_pos()
	var DST = -32 + 3*64 # 3 tiles de distancia
	
	# colisao com tiles
	# remove o tile numero 1 num raio DST
	var start = Vector2( cen.x - DST, cen.y - DST )
	var end = Vector2( cen.x + DST, cen.y + DST )
	var y = start.y
	while y<end.y:
		var x= start.x
		while x<end.x:
			var pos = Vector2( x,y )
			pos.x = floor(pos.x/64.0)
			pos.y = floor(pos.y/64.0)
			print(pos)
			if pos.x>0 and pos.x<35:
				if pos.y>0 and pos.y<63:
					var tile = tileset.get_cell(pos.x,pos.y)
					if tile >= 0:
						var d = sqrt( pow(x-cen.x,2) + pow(y-cen.y,2) )
						if d<DST:
							tileset.set_cell(pos.x,pos.y,-1)
							playerDT.detonade_tiles.push_back( pos )
			x += 64
		y += 64
		
	# colisao com os inimigos
	for inimigo in get_scene().get_nodes_in_group("inimigos"):
		var p = inimigo.get_pos()
		var d = pow(p.x-cen.x,2) + pow(p.y-cen.y,2)
		if d<SQRAD:
			inimigo.incHealt( -800 )
			playerDT.kills += 1
	
	# colisao com o player
	var p =cen.distance_squared_to(player.get_pos())
	if p < SQRAD :
		if p<(SQRAD*0.6): # area mortal = 60% do centro
			playerDT.incHealt(-1000)
		else: # dano moderado
			playerDT.incHealt( -80*(p/SQRAD) )

	

func _draw():
	draw_rect( Rect2(-MRAD,-MRAD,MRAD,MRAD2), Color(0,0,0,1) )
	if hp>0:
		draw_circle( Vector2(0,0), rad, Color(0.2,0.2,0) )
		draw_circle( Vector2(0,0), rad*0.8, Color(0.5,0.1,0) )
		draw_circle( Vector2(0,0), rad*0.5, Color(0.9,0.1,0,1) )
	
func _process(delta):
	if not playerDT.game_running:
		return
	
	hp -= TIMEDEC*delta
	if (hp>0):
		var s = hp*0.01
		bar.set_scale(Vector2(s,1))
		
		rad += (MRAD-rad) * (6 + 5*(1.0-s)) * delta
		if floor(rad) >= TRAD:
			rad = 0
			sound.play("blip")
		update()
	else:
		if kabum == false:
			kabum = true
			anim.play("explode")
			get_node("bomb").set_opacity(0)
			update()
			radialDestruction()
			sound.play("bomb")
		if anim.get_current_animation_pos() == anim.get_current_animation_length() :
			set_process(false)
			get_parent().remove_child(self)
	

func _ready():
	player = get_parent().get_node("Player")
	playerDT = get_node("/root/playerdata")
	bar = get_node("bar")
	anim = get_node("anim")
	sound = get_node("SamplePlayer2D")
	
	set_process(true)
