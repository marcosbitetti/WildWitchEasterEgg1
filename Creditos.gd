
extends Node

const VEL = 30
const MAX = 3400
const BGMAX = 620
var dif = 0

var body = null
var fundo = null
var t1 = 0
var parte = 0
var delay = 0

func _process(delta):
	delay += delta
	
	if parte == 0 :
		var p = body.get_pos()
		p.y -= VEL*delta
		
		var r = abs(p.y) / MAX
		var y = dif * r
		fundo.set_pos(Vector2(0,y))
		
		if p.y<-MAX:
			parte = 1
		
		body.set_pos(p)
	elif parte == 1 :
		t1 += delta
		if t1>4 :
			parte = 2
	elif parte == 2 :
		var p = fundo.get_pos()
		p.y -= p.y*delta
		fundo.set_pos(p)
		if round(p.y)==0 :
			fundo.set_pos(Vector2(0,0))
			body.set_pos(Vector2(0,273))
			parte = 0
	
	var magic_act = Input.is_action_pressed("magic_act")
	var barra_espaco = Input.is_action_pressed("barra_espaco")
	if delay>1 :
		if magic_act or barra_espaco:
			get_node("/root/playerdata").swap_scene("res://menu.scn")


func _ready():
	fundo = get_node("fundo")
	body = get_node("texto")
	dif = -fundo.get_node("bg").get_pos().y
	fundo.set_pos(Vector2(0,273))
	set_process(true)
	
	if get_node("/root/playerdata").tocarMusica:
		get_node("music").play()


