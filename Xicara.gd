
extends RigidBody2D

func end():
	set_block_signals(true)
	set_contact_monitor( false )
	set_active( false )
	queue_free()
	#get_parent().remove_child( self )

func _integrate_forces( state ):
	if get_pos().y > 700:
		end()
	
func _ready():
	pass
	