
extends Node2D

const FRAME = 0.15
const SPEED = 50

var frame = 0
var time = 0
var node = null
var tileref = null
var tilemap = null
var reg = Rect2(192,0,64,64)
var tile = 1000

func _process(delta):
	time += delta
	if time>=FRAME:
		time = 0
		frame += 1
		if frame > 3:
			frame = 0
		for sp in node.get_children():
			sp.set_frame(frame)
	
	var v = get_pos()
	v.y -= SPEED * delta
	
	var d = v.y - floor(v.y / 64.0)*64
	reg.size.y = 64 - d
	reg.pos.y = 128 + d
	for tl in tileref.get_children():
		tl.set_region_rect( reg )
	
	if v.y>0 and v.y<4000:
		var tlY = floor((v.y+128.0)/64.0)
		if tlY<tile:
			tile = tlY
			for x in range(0,36):
				tilemap. set_cell( x, tile, 6)
	
	set_pos( v )
	
	

func init():
	show()
	get_node("particles").set_emitting(true)
	tilemap = get_parent().get_node("TileMap")
	set_process(true)

func _ready():
	node = get_node("Node")
	tileref = get_node("redesenho")
	
	if get_node("/root/playerdata").fly_mode==1:
		init()


