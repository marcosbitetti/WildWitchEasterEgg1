
extends CanvasLayer

var rad = 0
const MRAD = 300

func _process(delta):
	rad += (MRAD-rad) * .3 * delta
	
	draw_circle( Vector2(0,0), rad, Color(1,1,1) )

func _ready():
	set_process(true)


