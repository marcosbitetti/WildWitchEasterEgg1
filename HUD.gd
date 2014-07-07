
extends CanvasLayer

# member variables here, example:
# var a=2
# var b="textvar"

var playerDT = null
var player = null
var mana_bar = null
var healt_bar = null
var avatar = null
var avatar_frame = 0
var info = null

var cartas_textos = [
	"Um espírito de um homem bom que morreu lutando por sua causa sem vê-la conquistada.\nA sede de vingança desse espírito destruira qualquer inimigo que toque.",
	"Criada a muitos anos por um mago louco, este artefato é louco para explodir e levar TUDO oque estiver pela frente.",
	"Projeta o espirito do portador de forma que ande livremente sem ser visto. Mas ainda pode tocar objetos.",
	""
]


###
#
# Controles do Grimoire
#
###
var magic_book_is_visible = false
var animation1 = null

var book_page = 0
var book_cursor = Vector2(0,0)

var cartas_array = []
var cartas_lin = [] # matrix para tabela das cartas
var card_icon = preload("res://CarataIcon.scn")
var card_selected = null



func add_card( tipo ):
	var c = card_icon.instance()
	c.get_node("imagem").set_frame( tipo )
	cartas_array.push_back( c )
	get_node("hud2/cartas").add_child( c )
	organiza_cartas()

func organiza_cartas():
	var x = 0
	var y = 0
	var cartas_row = []
	cartas_lin.clear()
	cartas_lin.push_back( cartas_row )
	card_selected = null
	for ct in cartas_array:
		cartas_row.push_back( ct )
		ct.set_pos( Vector2(x,y) )
		ct.set_rot( rand_range( -0.28,0.34) )
		x += 69
		if x>200:
			x = 0
			y += 80
			cartas_row = []
			cartas_lin.push_back( cartas_row )


var acum_delta = 0

func process_actions(delta):
	var move_left = Input.is_action_pressed("move_left")
	var move_right = Input.is_action_pressed("move_right")
	var move_up = Input.is_action_pressed("move_up")
	var move_down = Input.is_action_pressed("move_down")
	var barra_espaco = Input.is_action_pressed("barra_espaco")
	var esc_key = Input.is_action_pressed("esc_key")
	
	# previne interação excessiva
	acum_delta += delta
	if acum_delta<.15 and ( not move_left or not move_right or not move_up or not move_down or not barra_espaco):
		return
	acum_delta = 0
	
	if barra_espaco:
		if card_selected != null :
			# se a magia funcionou remove a carta da lista
			if player.iniciar_magia( card_selected.get_node("imagem").get_frame() ) :
				magic_book_is_visible = true
				show_magic_book()
				cartas_array.remove( cartas_array.find( card_selected ) )
				get_node("hud2/cartas").remove_child( card_selected )
				card_selected = null
				organiza_cartas()
				return
	
	if cartas_lin.size()>0:
		if move_right:
			book_cursor.x += 1
			if book_cursor.x >= cartas_lin[0].size():
				book_cursor.x = 0
		elif move_left:
			book_cursor.x -= 1
			if book_cursor.x < 0:
				book_cursor.x =  cartas_lin[0].size() - 1
		if move_down:
			book_cursor.y += 1
			if book_cursor.y >= cartas_lin.size():
				book_cursor.y = 0
		elif move_up:
			book_cursor.y -= 1
			if book_cursor.y < 0:
				book_cursor.y =  cartas_lin.size() - 1
	
	var card = card_selected
	if book_cursor.y < cartas_lin.size():
		if book_cursor.x < cartas_lin[book_cursor.y].size() :
			card = cartas_lin[book_cursor.y][book_cursor.x]
	
	if card != card_selected:
		if card_selected != null :
			card_selected.get_node("animacao").play("normal")
		card_selected = card
		if card_selected != null :
			card_selected.get_node("animacao").play("selecionada")
		get_node("hud2/gravuras").show()
		get_node("hud2/carta_info").show()
		get_node("hud2/gravuras").set_frame( card.get_node("imagem").get_frame() )
		get_node("hud2/carta_info").set_text( cartas_textos[card.get_node("imagem").get_frame()] )
	
	if esc_key:
		playerDT.swap_scene("res://menu.scn")


func show_magic_book():
	if animation1.get_current_animation_pos()==0 or (animation1.get_current_animation_pos() == animation1.get_current_animation_length()):
		if not magic_book_is_visible:
			magic_book_is_visible = true
			animation1.play("showbook")
			playerDT.game_running = false
			
		else:
			magic_book_is_visible = false
			animation1.play("hidebook")
			playerDT.game_running = true


# Anima as barrinhas de energia
func _process(delta):
	var sc = healt_bar.get_scale()
	sc.x += ((playerDT.healt*0.01) - sc.x ) * 5.0 * delta
	healt_bar.set_scale( sc )
	
	sc = mana_bar.get_scale()
	sc.x += ((playerDT.mana*0.01) - sc.x ) * 5.0 * delta
	mana_bar.set_scale( sc )
	
	# definie imagem
	if (playerDT.healt<=0):
		avatar_frame = 4
	elif (playerDT.healt<40):
		avatar_frame = 3
	elif (playerDT.healt<65):
		avatar_frame = 2
	elif (playerDT.healt<80):
		avatar_frame = 1
	else:
		avatar_frame = 0
	if (avatar_frame != avatar.get_frame()):
		avatar.set_frame(avatar_frame)
	
	if magic_book_is_visible:
		process_actions(delta)
	if playerDT.isDebug :
		var tx = "FPS                 : " + str( Performance.get_monitor( Performance.TIME_FPS ) ) + "\n"
		if DEBUG_MODE: 
			tx	  += "OBJECT_COUNT        : " + str( Performance.get_monitor(Performance.OBJECT_COUNT) ) + "\n"
			tx	  += "OBJECT_RESOURCE_COUN: " + str( Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT) ) + "\n"
			tx	  += "MEMORY_STATIC       : " + str( Performance.get_monitor(Performance.MEMORY_STATIC) ) + "\n"
			tx	  += "MEMORY_DYNAMIC      : " + str( Performance.get_monitor(Performance.MEMORY_DYNAMIC) ) + "\n"
			tx	  += "TIME_PROCESS        : " + str( Performance.get_monitor(Performance.TIME_PROCESS) ) + "\n"
			tx	  += "TIME_FIXED_PROCESS  : " + str( Performance.get_monitor(Performance.TIME_FIXED_PROCESS) )
		
		if debug:
			debug.set_text( tx )
	
	if _show_info>0:
		_show_info -= delta
		var y = sin(pow(INFO_TIME-_show_info,2))
		if y>0:
			if not info.is_visible():
				info.show()
		else:
			if info.is_visible():
				info.hide()
		if _show_info <= 0:
			_show_info = 0
			info.hide()
			
var debug = null
const DEBUG_MODE = false

func _ready():
	
	player = get_parent().get_node("Player")
	playerDT = get_node("/root/playerdata")
	healt_bar = get_node("hud1/healt_bar")
	mana_bar = get_node("hud1/mana_bar")
	avatar = get_node("hud1/avatar")
	animation1 = get_node("hud2/animation")
	info = get_node("hud1/info")
	avatar_frame = 0

	get_node("hud2/gravuras").hide()
	get_node("hud2/carta_info").hide()

	debug = get_node("debug")
	if not playerDT.isDebug:
		debug.hide()
		
	set_process(true)

func show_info(i):
	info.set_text(infos[i])
	info.show()
	_show_info = INFO_TIME


var infos = [
	"Descobriu passagem secreta!",
	"Descoriu Benção escondida!"
]
var _show_info = 0
const INFO_TIME = 5


# funcao disparada pelo objeto secreto escondido na cena
var tunel1Trigged = false
var tunel2Trigged = false
var segredo1Trigged = false

func _on_tunel1_body_enter( body ):
	var isGhost = body.get("ghost_mode")
	if isGhost != null: # é o player
		if not tunel1Trigged:
			tunel1Trigged = true
			show_info(0)
			playerDT.segredos_coletados.push_back("tunel1")
	


func _on_segredo1_body_enter( body ):
	var isGhost = body.get("ghost_mode")
	if isGhost != null: # é o player
		if not segredo1Trigged:
			segredo1Trigged = true
			show_info(1)
			playerDT.segredos_coletados.push_back("segredo1")
			playerDT.incHealt(28)
			playerDT.incMana(22)


func _on_tunel2_body_enter( body ):
	var isGhost = body.get("ghost_mode")
	if isGhost != null: # é o player
		if not tunel2Trigged:
			tunel2Trigged = true
			show_info(0)
			playerDT.segredos_coletados.push_back("tunel2")
