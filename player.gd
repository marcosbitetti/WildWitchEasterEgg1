
extends RigidBody2D

# member variables here, example:
# var a=2
# var b="textvar"

const WALK_ACCEL = 800.0
const WALK_DEACCEL= 800.0
const WALK_MAX_VELOCITY = 200.0
const FLY_VELOCITY = 100.0
const GRAVITY = 700.0
const AIR_ACCEL = 200.0
const AIR_DEACCEL= 200.0
const JUMP_VELOCITY=80
const STOP_JUMP_FORCE=900.0

const GHOST_TIME = 10

var floor_h_velocity = 0.0
var body = null
var pulando = false
var caindo = false
var ponto_de_queda = null # para medir a distancia da queda
const TS = 1.0 / 64.0 # divisor para tile
var anim_s = "parada"
var isMorta = false
var spans = []

var data = null
var anim = null
var tilemap = null
var hud = null
var sampler = null
var poderes = null
var asas = null
var lava = null
var lava_tm = 0

var mode = 1

var magic1 = null
var magic2 = null
var magic3 = null
var magicObjs = [] # esta var vai conter a lista de objetos magic1 conectados 
var ghost_mode = false
var ghost_time = 0
var ghost_bar = null
var ghost_body = null

var blood = null

var m_move_left = false
var m_move_right = false
var m_move_up = false
var m_move_down = false

func adicionarCarta(tipo,nome):
	var t = -1
	if tipo == "aliado_macabro":
		t = 0
	elif tipo == "explosiva":
		t = 1
	elif tipo == "projecao_astral":
		t = 2
	data.cartas_coletadas.push_back(nome)
	data.cartas_usadas += 1
	hud.add_card( t )

const MG_ALIADO_CUSTO = 20
const MG_BOMBA_CUSTO = 45
const MG_PROJECAO_CUSTO = 60

func iniciar_magia(tipo):
	var pos = get_pos()
	pos.x += 32
	pos.y += 64
	var isOk = false
	
	# Aliado Macabro
	if tipo == 0:
		if data.mana>MG_ALIADO_CUSTO :
			data.incMana(-MG_ALIADO_CUSTO)
			isOk = true
			if magic1 == null:
				magic1 = preload("res://AliadoMacrabo.scn")
			for i in range(2):
				var aliado = magic1.instance()
				aliado.set_pos( pos )
				poderes.add_child(aliado)
				PS2D.body_add_collision_exception(aliado.get_rid(),get_rid())
			var dif = (PI*2.0) / poderes.get_child_count()
			var a = -PI + dif
			#print("n " + str(poderes.get_child_count()))
			for ob in poderes.get_children() :
				#print("dif " + str(a))
				ob.vec = Vector2(1.0,0.0).rotated( a )
				a += dif
	
	# Bomba Fantasma
	if tipo == 1:
		if data.mana>MG_BOMBA_CUSTO :
			data.incMana(-MG_BOMBA_CUSTO)
			isOk = true
			if magic2 == null:
				magic2 = preload("res://BombaFantasma.scn")
			var bomba = magic2.instance()
			var p = get_pos()
			p.y += 32
			bomba.set_pos(p)
			get_parent().add_child(bomba)
	
	if tipo == 2:
		if data.mana>MG_PROJECAO_CUSTO :
			data.incMana(-MG_PROJECAO_CUSTO)
			isOk = true
			if magic3 == null:
				magic3 = preload("res://CorpoPlayerClone.scn")
			ghost_time = GHOST_TIME
			set_opacity(0.5)
			ghost_bar.show()
			ghost_body = magic3.instance()
			ghost_body.set_pos( get_pos() )
			ghost_body.set_scale( body.get_scale() )
			PS2D.body_add_collision_exception(ghost_body.get_rid(),get_rid())
			get_parent().add_child( ghost_body )
			ghost_mode = true
	
	if isOk:
		data.cartas_usadas += 1
	
	return isOk

func showBlood(pos):
	var sang = blood.instance()
	sang.set_pos( pos )
	get_parent().add_child( sang )

func showDano():
	if not isMorta:
		var p = get_pos()
		p.y -= 64
		showBlood(p)
		sampler.play("womanscream1")
		if data.healt<1 and not isMorta:
			isMorta = true
			body.hide()
			get_node("morta").show()
			data.game_running = false
			get_parent().get_node("Timer").start()
			data.mortes += 1
			#get_node("/root/stage/Timer").start()

func _integrate_forces(s):
		
	var lv = s.get_linear_velocity()
	var step = s.get_step()
	
	# Get the controls
	var move_left = Input.is_action_pressed("move_left")
	var move_right = Input.is_action_pressed("move_right")
	var move_up = Input.is_action_pressed("move_up")
	var move_down = Input.is_action_pressed("move_down")
	var magic_act = Input.is_action_pressed("magic_act")
	var anim_ = anim_s
	
	if magic_act:
		hud.show_magic_book()
		return
	
	if not data.game_running:
		return
		
	data.tempo_total += step
	
	var pos = get_pos()
	var box = [pos.x-32,pos.y-64,pos.x+32,pos.y+64]
	
	# ponto de nascimento
	var span_index = 0
	for sp in spans:
		if pos.y > sp.y :
			if span_index > data.span_index:
				data.span_index = span_index
		span_index += 1
			
	
	
	# matar
	for e in data.lista_mortos:
		#print(e)
		#print(box)
		# escala os testes (não é tão necessário mais ha contas que tenho medo que ocorram
		# y é o maior eixo
		if (e.box.pos.y>=box[1] and e.box.pos.y<box[3]) or (e.box.size.y>=box[1] and e.box.size.y<box[3]) :
			if (e.box.pos.x>=box[0] and e.box.pos.x<box[2]) or (e.box.size.x>=box[0] and e.box.size.x<box[2]) :
				e.me.end()
				data.incHealt(e.dano)
	data.lista_mortos.clear()
	
	if data.fly_mode==1:
		anim_ = "fly"
		if (anim_ != anim_s):
			asas.show()
			anim_s = anim_
			anim.play(anim_s)
		
		
		lv.x = 0
		lv.y = 0
		if move_up:
			lv.y = -FLY_VELOCITY
		elif move_down:
			lv.y = FLY_VELOCITY
		if move_left:
			lv.x = -FLY_VELOCITY
			body.set_scale(Vector2(1.0,1.0))
		elif move_right:
			lv.x = FLY_VELOCITY
			body.set_scale(Vector2(-1.0,1.0))
		
		asas.set_scale(body.get_scale())
		
		s.set_linear_velocity(lv)
		
		# dano por lava
		lava_tm += step
		if lava.get_pos().y<box[3] and lava_tm>0.8 :
			data.incHealt(-5)
			lava_tm = 0
		
		
		return
	
	var onFloor = false
	var onEscada = false
	var onParede = false
	var floor_index=-1
	
	# Find the floor (a contact with upwards facing collision normal)
	for x in range(s.get_contact_count()):

		var ci = s.get_contact_local_normal(x)
		# vou discartar o dot product para ter um valor mais exato de ny
		#if (ci.dot(Vector2(0,-1))>0.6):
		if ci.x<-0.1 or ci.x>0.1:
			onParede = true
		if ci.y<-0.5 :
			onFloor=true
			floor_index=x
		elif ( abs(ci.x)>0.6 and lv.y<-0.0): #lv.y<-0.1):
			lv.y = -JUMP_VELOCITY
			lv.x = 0
			onFloor = true
			caindo = false
			pulando = false
	
	var t = get_pos()
	t.x -= 32
	t *= TS
	if(tilemap.get_cell( round(t.x), round(t.y) )==2): # na escada
		onEscada = true
	
	# MOVIMENTO
	if onFloor and not onEscada :
		
		# direcao visual
		if (move_left and not move_right):
			if (lv.x > -WALK_MAX_VELOCITY):
				lv.x-=WALK_ACCEL*step
				body.set_scale( Vector2(1.0,1.0) )
				anim_ = "correr"
		elif (move_right and not move_left):
			if (lv.x < WALK_MAX_VELOCITY):
				lv.x+=WALK_ACCEL*step
				body.set_scale( Vector2(-1.0,1.0) )
				anim_ = "correr"
		
		# movimento
		if move_left and not move_right:
			lv.x = -WALK_MAX_VELOCITY
		elif move_right and not move_left:
			lv.x = WALK_MAX_VELOCITY
		else:
			lv.x=t.x*0.3*step
		
		# pulo
		if not pulando and move_up:
			lv.y=-310
			pulando = true
			caindo = false
			anim_ = "pular"
		
		if caindo :
			caindo = false
			pulando = false
			onFloor = true
			#print("queda " + str(ponto_de_queda.y - get_pos().y))
			ponto_de_queda = null
			anim_ = "parada"
		
		if onFloor and not caindo and not pulando and not move_left and not move_right:
			anim_ = "parada"
			
	elif not onFloor and not onEscada :
		lv.y += (GRAVITY-lv.y) * 0.8 * step
		if lv.y>30 : # necessita um valor maior q zero para prevenir problema nas emandas dos tiles
			#print(lv.y)
			caindo = true
			if ponto_de_queda==null :
				ponto_de_queda = get_pos()
			anim_ = "caindo"
	elif onEscada :
		#lv = s.get_linear_velocity() * Vector2(-1.0,-1.0) # para queda
		lv.x = 0
		lv.y = 0
		anim_ = "paradaescada"
		if move_left and not move_right :
			body.set_scale( Vector2(1.0,1.0) )
			lv.x=-WALK_MAX_VELOCITY*0.4
			if onParede:
				lv.y = WALK_MAX_VELOCITY*.3
		elif move_right and not move_left :
			body.set_scale( Vector2(-1.0,1.0) )
			lv.x=WALK_MAX_VELOCITY*0.4
			if onParede:
				lv.y = WALK_MAX_VELOCITY*.3
		if move_up and not move_down:
			anim_ = "escalar"
			lv.y=-WALK_MAX_VELOCITY*0.7
		elif move_down and not move_up:
			anim_ = "escalar"
			lv.y=WALK_MAX_VELOCITY*.7
	
	if onParede and lv.y<0 and not onEscada:
		lv.y = 0
		
	if (anim_ != anim_s):
		anim_s = anim_
		anim.play(anim_s)
		
	if ghost_mode:
		ghost_time -= step
		if ghost_time <=0 :
			ghost_bar.hide()
			set_opacity( 1.0 )
			call_deferred("set_pos",ghost_body.get_pos())
			ghost_body.queue_free()
			ghost_body = null
			ghost_mode = false
		else:
			var s = get_scale()
			s.x *= ghost_time / GHOST_TIME
			ghost_bar.set_scale(s)

	#print(get_pos()) # acertar camera

	#lv+=s.get_total_gravity()*step
	s.set_linear_velocity(lv)

func init():
	body = get_node("Sprite")
	anim = get_node("anim")
	data = get_node("/root/playerdata")
	sampler = get_node("sampler")
	tilemap = get_parent().get_node("TileMap")
	hud = get_parent().get_node("HUD")
	ghost_bar = get_node("ghost_bar")
	blood = preload("res://Sangue.scn")
	poderes = get_parent().get_node("poderes")
	asas = get_node("asas")
	lava = get_parent().get_node("Lava")

func _ready():
	init()



