
extends Node

const RAD = 0.017453293
const TEMPO = 1
const ENDT = 75

var Bolacha = preload("res://Bolacha.scn")
var Xicara = preload("res://Xicara.scn")
var Morcego = preload("res://Morcego2.scn")
var SoulEater = preload("res://SoulEater.scn")

var shoot1 = TEMPO
var aTime = 0
var rand_monster = 0.5
var ponteiro = null
var passes = [ ENDT*0.2, ENDT*0.5, ENDT*0.7 ]

func _process(delta):
	
	# tiro
	shoot1 -= delta
	if shoot1<=0 :
		if randf()<0.5 :
			var p = Vector2(810,660)
			var ang = rand_range(100,140)
			var vel = Vector2(rand_range(320,490),0).rotated(RAD*ang)
			
			var bolacha = Bolacha.instance()
			bolacha.set_pos( p )
			bolacha.set_linear_velocity(vel)
			shoot1 = TEMPO
			add_child(bolacha)
		else:
			var p = Vector2(rand_range(100,700),-128)
			var xicara = Xicara.instance()
			xicara.set_pos( p )
			shoot1 = TEMPO
			add_child(xicara)
		
		# inimigos
		if aTime>passes[2]:
			rand_monster = 0.9
		elif aTime>passes[1]:
			rand_monster = 0.6
		elif aTime>passes[0]:
			rand_monster = 0.4
		print(rand_monster)
		
		if randf()<rand_monster:
			if randf()<0.5:
				var morcego = Morcego.instance()
				add_child(morcego)
			else:
				var souleater = SoulEater.instance()
				add_child(souleater)
	
	# ponteiro
	aTime += delta
	var p = Vector2( 163 + 445 * (aTime/ENDT) ,453)
	ponteiro.set_pos(p)
	if aTime>=ENDT :
		var dt = get_node("/root/playerdata")
		#dt.info = "cena2"
		#dt.swap_scene("res://CeuSelection.scn")
		dt.swap_scene("res://main.scn")


func _ready():
	ponteiro = get_node("HUD2/ponteiro")
	
	if get_node("/root/playerdata").tocarMusica:
		if get_node("music"):
			get_node("music").play()
	
	set_process(true)




# atualiza estatísticas
func _on_exit_scene():
	get_node("/root/playerdata").saveConfig()
