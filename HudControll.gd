
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

var move_left = false
var move_right = false

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
	
	

func _ready():
	
	player = get_node("/root/stage/Player")
	playerDT = get_node("/root/playerdata")
	healt_bar = get_node("hud_char/healt_bar")
	mana_bar = get_node("hud_char/mana_bar")
	avatar = get_node("hud_char/healt_image")
	avatar_frame = 0 #avatar.get_frame()
	
	set_process(true)



func _on_right_pressed():
	move_right = true


func _on_right_release():
	move_right = false


func _on_left_pressed():
	move_left = true


func _on_left_release():
	move_left = false


func _on_jump_pressed():
	player.m_move_up = true


func _on_jump_release():
	player.m_move_up = false
