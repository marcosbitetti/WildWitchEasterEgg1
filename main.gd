
extends Node


func clearTilesDestruidos():
	var tileset = get_node("TileMap")
	for pos in get_node("/root/playerdata").detonade_tiles:
		tileset.set_cell(pos.x,pos.y,-1)

func clearSegredosDaCena():
	for segredo in get_node("/root/playerdata").segredos_coletados:
		var s = get_node("segredos/"+segredo)
		if s != null:
			s.queue_free()

func clearCartasDaCena():
	for ct in get_node("/root/playerdata").cartas_coletadas:
		var nd = get_node("itens/"+ct)
		if nd != null:
			nd.queue_free()

func clearPedrasDaCena():
	for pd in get_node("/root/playerdata").itens_coletados:
		var nd = get_node("itens/"+pd)
		if nd != null:
			nd.queue_free()

func contaCartasEItens():
	var data = get_node("/root/playerdata")
	var cartas = 0
	var pedras = 0
	for node in get_node("itens").get_children():
		var tp = node.get("tipo")
		if tp != null:
			if tp=="carta":
				cartas += 1
			if tp=="healt" or tp=="mana":
				pedras += 1
	
	if cartas>data.cartas_total:
		data.cartas_total = cartas
	if pedras>data.pedras_total:
		data.pedras_total = pedras


func _on_Timer_timeout():
	get_node("/root/playerdata").swap_scene("res://CeuSelection.scn")



func _ready():
	if get_node("/root/playerdata").tocarMusica:
		get_node("music").play()
	
	var dt = get_node("/root/playerdata")
	dt.base = self
	dt.game_running = true
	
	clearTilesDestruidos()
	clearSegredosDaCena()
	contaCartasEItens()
	clearCartasDaCena()
	clearPedrasDaCena()
	
	var spans = []
	for span in get_node("spans_points").get_children():
		spans.push_back( span.get_pos() )
	
	get_node("Player").set_pos( spans[dt.span_index] )
	get_node("Player").spans = spans
	
	pass

# atualiza estatísticas
func _on_exit_scene():
	get_node("/root/playerdata").saveConfig()


func _on_saida_body_enter( body ):
	get_node("/root/playerdata").abrir_estatisticas = true
	get_node("/root/playerdata").swap_scene("res://final.scn")
