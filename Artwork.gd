
extends Node

const MOV = 320
const DIS = 290

var main = null
var view = null
var med = 400
var spans = []

func _process(delta):
	var move_left = Input.is_action_pressed("move_left")
	var move_right = Input.is_action_pressed("move_right")
	var move_up = Input.is_action_pressed("move_up")
	var move_down = Input.is_action_pressed("move_down")
	var magic_act = Input.is_action_pressed("magic_act")
	var barra_espaco = Input.is_action_pressed("barra_espaco")
	
	var x = main.get_pos().x
	
	if move_left:
		x += MOV*delta
		if x>200:
			x = 200
	elif move_right:
		x -= MOV*delta
		if x<-4080:
			x = -4080
	#print(x)
	
	for i in range(main.get_child_count()):
		var v = main.get_child(i)
		var s = v.get_child(1).get_texture().get_height() # sprite de desenho
		var tX = v.get_pos().x + x # normaliza a cordenada do objeto
		if tX>0 and tX<view.width:
			var dis = abs(med[0]-tX)
			if dis<DIS:
				dis = 1.0 - (dis/DIS)
				var r = dis*dis
				var ms = (view.height / s) - 1.0
				var p = med[1] - spans[i].y
				v.set_scale(Vector2(1.0+ms*r,1.0+ms*r))
				v.set_pos(Vector2(spans[i].x,spans[i].y+p*r))
				
	
	if barra_espaco or magic_act:
		get_node("/root/playerdata").swap_scene("res://menu.scn")
	
	main.set_pos(Vector2(x,0))

func _ready():
	main = get_node("imagens")
	# quadro no meio
	view = main.get_viewport_rect().size
	med = [ view.width * 0.5, view.height * 0.5 ]
	for i in range(main.get_child_count()):
		spans.push_back( main.get_child(i).get_pos() )
		
	set_process(true)
	
	if get_node("/root/playerdata").tocarMusica:
		if get_node("music"):
			get_node("music").play()


