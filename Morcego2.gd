
extends RigidBody2D

const VEL = 200

var cur = rand_range(10,100)
var span = null
var s = PI*2
var R = PI/180
var tim = 1.2
var emi = null

func end():
	set_block_signals(true)
	set_contact_monitor( false )
	set_active( false )
	queue_free()
		
func _integrate_forces( state ):
	var step = state.get_step()
	#var _lv = state.get_linear_velocity()
	var lv = Vector2(-VEL,0)
	
	var p = get_pos()
	
	if p.x<-128:
		end()
		pass
		
	s -= R*2
	lv.y = sin(s)*cur
	
	state.set_linear_velocity(lv)
	
	if emi.is_emitting():
		tim -= step
		if tim<0 :
			end()
	

func _ready():
	#span = Vector2(920, rand_range(100,566) )
	var p = get_node("/root/stage/Player").get_pos()
	span = Vector2(920, p.y + rand_range(-100,100) )
	set_pos(span)
	
	emi = get_node("emi")


