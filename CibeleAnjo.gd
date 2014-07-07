
extends RigidBody2D


const VEL = 140
const samples = ["chewing", "womanscream1", "yeahh"]

var playerDT = null
var sample = null
var olhos = null
var emissor = null
var dTime1 = 0
var aTime = 0


func showDano():
	pass

func _process(delta):
	aTime += delta
	
	if aTime>=dTime1:
		if olhos.get_frame()==0 :
			olhos.set_frame(1)
			dTime1 = aTime + 0.3
		else:
			olhos.set_frame(0)
			dTime1 = aTime + rand_range(1,4)
	
	var s = get_scale().x
	emissor.set_param( Particles2D.PARAM_INITIAL_SIZE, 0.4*s)
	emissor.set_param( Particles2D.PARAM_GRAVITY_STRENGTH, 100*s)
	emissor.set_param( Particles2D.PARAM_LINEAR_VELOCITY, 20*s)
	
	#set_pos(p)

func _integrate_forces( state ):
	var _lv = state.get_linear_velocity()
	var lv = Vector2(0,0)
	var step = state.get_step()
	
	playerDT.tempo_total += step
	
	# processa controles
	var move_left = Input.is_action_pressed("move_left")
	var move_right = Input.is_action_pressed("move_right")
	var move_up = Input.is_action_pressed("move_up")
	var move_down = Input.is_action_pressed("move_down")
	var magic_act = Input.is_action_pressed("magic_act")
	
	var p = get_pos()
	
	if move_up:
		if p.y>48:
			lv.y -= VEL
			set_rot(0.3)
	elif move_down:
		if p.y<580 :
			lv.y+= VEL
			set_rot(-0.3)
	if move_left:
		if p.x>64 :
			lv.x -= VEL
	elif move_right:
		if p.x<746 :
			lv.x+= VEL
	#if not move_up and not move_down:
	#	set_rot(0)
	
	#lv+=state.get_total_gravity()*step
	state.set_linear_velocity(lv)


func _on_body_enter( body ):
	if body:
		var sp = body.get_node("Sprite")
		if sp :
			if sp.get_frame() == 1:
				playerDT.incMana(12)
				sample.play(samples[2])
			else:
				playerDT.incHealt(5)
				sample.play(samples[0])
			body.set_block_signals(true)
			body.set_contact_monitor( false )
			body.set_active( false )
			body.queue_free()
		else:
			sp = body.get_node("morcego")
			if sp :
				sp.hide()
				playerDT.incHealt(-20)
				body.get_node("emi").set_emitting(true)
				sample.play(samples[1])
			else:
				sp = body.get_node("souleater")
				if sp :
					sp.hide()
					playerDT.incMana(-20)
					body.get_node("emi").set_emitting(true)
					sample.play(samples[1])
		
		#body.get_parent().remove_child( body )


func _ready():
	olhos = get_node("olhos")
	emissor = get_node("emi")
	sample = get_node("SamplePlayer2D")
	playerDT = get_node("/root/playerdata")
	playerDT.incHealt(-100)
	playerDT.incMana(-100)
	
	set_process(true)
