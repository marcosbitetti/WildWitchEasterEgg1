extends Node

const GAME_VERSION = 10000

var healt = 2
var mana = 4
var fly_mode = 0

var game_running = true
var current_scene = null
var player = null
var base = null
var info = ""
var tocarMusica = true
var configCarregado = false
var isDebug = true

var checkUpdateFeito = false
var updates = []

# elementos alterados no cenario
var detonade_tiles = []
var inimigos_mortos = []
var itens_coletados = []
var segredos_coletados = []
var cartas_coletadas = []

# dados para estatisticas
var tempo_total = 0
var mortes = 0
var kills = 0
var mordidas = 0
var segredos = 0
var cartas_usadas = 0
var cartas_total = 0
var pedras_usadas = 0
var pedras_total = 0
var segredos_total = 4
var span_index = 0

var abrir_estatisticas = false


func carregaConfig():
	var file = File.new()
	var err = file.open("user://easteregg1.bin",File.READ)
	if err == OK:
		if not file.eof_reached():
			if file.get_line().to_int() <= GAME_VERSION:
				if not file.eof_reached():
					if file.get_line() == "True":
						tocarMusica = true
					else:
						tocarMusica = false
				if not file.eof_reached():
					if file.get_line() == "True":
						isDebug = true
					else:
						isDebug = false
				if not file.eof_reached():
					tempo_total = file.get_line().to_float()
				if not file.eof_reached():
					mortes = file.get_line().to_int()
				if not file.eof_reached():
					kills = file.get_line().to_int()
				if not file.eof_reached():
					mordidas = file.get_line().to_int()
				if not file.eof_reached():
					segredos = file.get_line().to_int()
				if not file.eof_reached():
					cartas_usadas = file.get_line().to_int()
				if not file.eof_reached():
					cartas_total = file.get_line().to_int()
				if not file.eof_reached():
					pedras_usadas = file.get_line().to_int()
				if not file.eof_reached():
					pedras_total = file.get_line().to_int()
					
		file.close()
	

func saveConfig():
	var file = File.new()
	var err = file.open("user://easteregg1.bin",File.WRITE)
	if err == OK:
		var saves = ["True","True"]
		if not tocarMusica:
			saves[0] = "False"
		if not isDebug:
			saves[1] = "False"
		
		file.store_line( str(GAME_VERSION) ) # salva versao do game para nao conflitar arquivos posteriormente
		file.store_line( saves[0] )
		file.store_line( saves[1] )
		file.store_line( str(tempo_total) )
		file.store_line( str(mortes) )
		file.store_line( str(kills) )
		file.store_line( str(mordidas) )
		file.store_line( str(segredos) )
		file.store_line( str(cartas_usadas) )
		file.store_line( str(cartas_total) )
		file.store_line( str(pedras_usadas) )
		file.store_line( str(pedras_total) )
		file.close()

# quando iniciar uma nova partida volta os valores estatisticos
func resetStats():
	tempo_total = 0
	mortes = 0
	kills = 0
	mordidas = 0
	segredos = 0
	cartas_usadas = 0
	pedras_usadas = 0


func incHealt(val):
	healt += val
	if (healt>100):
		healt = 100
	if (healt<0):
		healt = 0
	if val<0: # dano
		if not base==null:
			var p =base.get_node("Player")
			if p:
				p.showDano()
				mordidas += 1

func incMana(val):
	mana += val
	if (mana>100):
		mana = 100
	if (mana<0):
		mana = 0


###
# Mudança de estratégia nas colisões com inimigos
# devido a erros de escala que ocorrem em circustâncias que ainda não pude isolar.
# Os inimigos mandam sua instancia e bound-box para alimentar este array que é verificado
# no loop do player
###
var lista_mortos = []

func list_2_kill(dano,ob, pos, w,h):
	var b = {
		me= ob,
		box= Rect2(),
		dano= dano
	}
	b.box.pos = pos
	b.box.size = Vector2( pos.x+w,pos.y+h )
	lista_mortos.push_back( b )



func call_player():
	print("Parente ", base )
	get_node("/root/stage/Player").showDano()

func swap_scene(scene):
	var s = ResourceLoader.load(scene)
	player = null
	current_scene.queue_free()
	current_scene = s.instance()
	base = null
	get_scene().get_root().add_child(current_scene)
	player = get_node("/root/stage/Player")
	


func _ready():
	#player = get_node("/root/stage/Player")
	var root = get_scene().get_root()
	current_scene = root.get_child( root.get_child_count() -1 )

