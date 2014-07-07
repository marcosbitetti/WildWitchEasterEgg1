
extends Node

const KT = 0.15

var playerDT = null
var menuItens = null
var item = 0
var viewItem = 1
var last = 0
var tela = 0 # 0 - menu, 1-stats, 2-config
var lastTela = null
var loadHTML = Thread.new()
var sendForm = Thread.new()
var listItem = preload("res://listItem.scn")

#const url_updates = ["www.wildwitchproject.com","/"]
const url_updates = ["domain.com","/caminho/da/pagina/de/updates.html"]
const url_form = ["www.domain.com","/path/to/app"]

func bg_html(url):
	var ret = []
	var html = ""
	var err=0
	var http = HTTPClient.new()
	var err = http.connect(url[0],80)
	assert(err==OK)
	
	while( http.get_status()==HTTPClient.STATUS_CONNECTING or http.get_status()==HTTPClient.STATUS_RESOLVING):
		http.poll()
		print("Connecting...")
		OS.delay_msec(500)
	
	assert( http.get_status() == HTTPClient.STATUS_CONNECTED )
	
	var headers=[
		"Host: " + url[0],
		"Connection: keep-alive",
		#"Accept: */*",
		"Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
		"User-Agent: [You game signature here - seu cliente de jogo aqui]",
		"Accept-Charset: ISO-8859-1,utf-8;q=0.7,*;q=0.3",
		"Accept-Encoding: deflate", # Previni o envio de dados compactados, default: gzip,deflate
		"Accept-Language: pt-BR,pt;q=0.8,en-US;q=0.6,en;q=0.4"
	]	
	err = http.request(HTTPClient.METHOD_GET,url[1],headers)
	assert( err == OK )
	
	while (http.get_status() == HTTPClient.STATUS_REQUESTING):
		http.poll()
		print("Requesting..")
		OS.delay_msec(500)
	
	assert( http.get_status() == HTTPClient.STATUS_BODY or http.get_status() == HTTPClient.STATUS_CONNECTED )
	
	
	if (http.has_response()):
		# observa request
		var headers = http.get_response_headers_as_dictionary()
		for hd in headers:
			print( headers[hd] )
		print(http.get_response_code())
		
		print("code: ",http.get_response_code())
		print("**headers:\n",headers)
		
		var bl = 0
		if (http.is_response_chunked()):
			bl = -1
		else:
			bl = http.get_response_body_length()
		
		var rb = RawArray()
		while(http.get_status()==HTTPClient.STATUS_BODY):
			http.poll()
			var chunk = http.read_response_body_chunk()
			if (chunk.size()==0):
				OS.delay_usec(1000)
			else:
				rb = rb + chunk
		print(html)
		# se ouver dados trabalha
		if rb.size()>0:
			
			# prevenir BOM 
			for i in range(32):
				if rb.get(i)<32:
					rb.set(i,32)
					
			html = rb.get_string_from_ascii()
			#html = rb.get_string_from_utf8()
			print(html)
			var ini = html.find("<aside id=\"CabecalhoDeAtualizacaoWWP\"")
			var end = 0
			if ini<0:
				return null
			ini = html.find("<article",ini)
			
			while ini>0:
				ini += 8
				#dados
				ini = html.find("<meta itemprop=\"name\" content=\"",ini)
				end = html.find("\"",ini+31)
				var produto = html.substr(ini+31,end-ini-31)
				ini = html.find("<meta itemprop=\"review\" content=\"",ini)
				end = html.find("\"",ini+33)
				var review = html.substr(ini+33,end-ini-33)
				ini = html.find("<address",ini)
				var address = ""
				if ini>0:
					ini = html.find("href=\"",ini)
					end = html.find("\"",ini+6)
					address = html.substr(ini+6,end-ini-6)
				# review to int
				var iReview = review.replace(".","").to_int()
				print(produto," ",review," ",address, " " , iReview)
				
				ret.push_back( {
					produto = produto,
					review = review,
					iReview = iReview,
					address = address
				})
				ini = html.find("<article",ini)
				
	call_deferred("bg_html_done")
	return ret


func bg_html_done():
	var data = loadHTML.wait_to_finish()
	var base = get_node("atualizacoes/base")
	
	for i in range(base.get_child_count()) :
		var o = base.get_child(i)
		o.queue_free()
	
	var ativa = false
	var y = 0
	for dt in data:
		if dt.produto=="WWPEasterEgg1":
			var lbl =  listItem.instance()
			lbl.set_text(dt.produto)
			lbl.set_pos(Vector2(0,y))
			y += 38
			base.add_child(lbl)
			var but = Button.new()
			but.set_text("Atualizar")
			but.set_pos(Vector2(40,y))
			but.connect("pressed",self,"on_atualizar_pressed")
			base.add_child(but)
			
			update_link = dt.address
			botao_update = but
			
			ativa = true
		
	if not ativa:
		var lbl =  listItem.instance()
		lbl.set_text("sem updates")
		lbl.set_pos(Vector2(0,y))
		base.add_child(lbl)

var botao_update = null
var update_link = ""

func on_atualizar_pressed():
	botao_update.hide()
	print("download: " + update_link)
	
	var p = botao_update.get_pos()
	var l = listItem.instance()
	l.set_pos(p)
	l.set_text("Baixando, aguarde ...")
	get_node("atualizacoes/base").add_child(l)
	
	#OS.execute("Atualizador.exe",["-gamerodando","-url",update_link,"-nome","wwpeasteregg1.zip"],false)
	
	if OS.has_environment("windir"):
		OS.execute("Atualizador.exe",["-gamerodando","-url",update_link,"-nome","wwpeasteregg1.zip"],false)
	else:
		OS.execute("/bin/bash",["update.sh"],true)
	
	l.set_text("Pronto! Reinicie o jogo")




func _process(delta):
	var move_left = Input.is_action_pressed("move_left")
	var move_right = Input.is_action_pressed("move_right")
	var move_up = Input.is_action_pressed("move_up")
	var move_down = Input.is_action_pressed("move_down")
	var magic_act = Input.is_action_pressed("magic_act")
	var barra_espaco = Input.is_action_pressed("barra_espaco")
	
	last += delta
	
	# menu principal
	if tela==0:
	
		if last>KT:
			if move_up:
				last = 0
				item -= 1
				if item<0:
					item = 6
			elif move_down:
				last = 0
				item += 1
				if item>6:
					item = 0
			
			if barra_espaco or magic_act:
				last = 0
				lastTela.hide()
				if   item==0:
					playerDT.resetStats()
					loadHTML.wait_to_finish()
					playerDT.swap_scene("res://main.scn")
				elif item==1:
					tela = 1
					lastTela = get_node("estatisticas")
					calculeEstatisticas()
					lastTela.show()
				elif item==2:
					loadHTML.wait_to_finish()
					playerDT.swap_scene("res://Artwork.scn")
				elif item==3:
					loadHTML.wait_to_finish()
					playerDT.swap_scene("res://Creditos.scn")
				elif item==4:
					tela = 4
					lastTela = get_node("atualizacoes")
					lastTela.show()
				elif item==5:
					tela = 5
					lastTela = get_node("wwp")
					lastTela.show()
				elif item==6:
					tela = 6
					lastTela = get_node("configuracoes")
					lastTela.show()
		
		if viewItem != item:
			menuItens[viewItem].hide()
			menuItens[item].show()
			viewItem = item
		
	
	# statisticas
	elif tela==1 or tela==4 or tela==5:
		if last>KT:
			if barra_espaco or magic_act:
				last = 0
				tela = 0
				lastTela.hide()
				lastTela = get_node("menu")
				lastTela.show()

func formatTempo(t):
	var tf = float(t)
	var m = round( tf/60 )
	var s = round( tf - m*60 )
	return str(m) + " minutos e " + str(s) + " segundos"
	

func calculeEstatisticas():
	var text =get_node("estatisticas/stats")
	var texto = "ESTATÍSTICAS\n\n"
	if playerDT.pedras_total==0:
		texto += "Primeira partida"
	else:
		var tempo = playerDT.tempo_total
		texto += "Tempo: "+ formatTempo(tempo)+"\n\n"
		texto += "Mortes: "+ str(playerDT.mortes)+"\n\n"
		texto += "Kills: "+str(playerDT.kills)+"\n\n"
		texto += "Mordidas: "+str(playerDT.mordidas)+"\n\n"
		texto += "Segredos: "+str(playerDT.segredos)+"/"+str(playerDT.segredos_total)+"\n\n"
		texto += "Cartas: "+str(playerDT.cartas_usadas)+"/"+str(playerDT.cartas_total)+"\n\n"
		#texto += "Pedras: "+str(playerDT.pedras_usadas)+"/"+str(playerDT.pedras_total)
		
	text.set_text(texto)
	
func carregaConfig():
	playerDT.carregaConfig()
	get_node("configuracoes/tocar_musicas").set_pressed(playerDT.tocarMusica)
	get_node("configuracoes/mostrar_fps").set_pressed(playerDT.isDebug)
	

func saveConfig():
	playerDT.saveConfig()


###
# Formulario de comentario
###

func bg_form(url):
	var html = ""
	var err=0
	var http = HTTPClient.new()
	var err = http.connect(url[0],80)
	assert(err==OK)
	
	while( http.get_status()==HTTPClient.STATUS_CONNECTING or http.get_status()==HTTPClient.STATUS_RESOLVING):
		http.poll()
		print("Connecting... http://" + url[0] + url[1] )
		OS.delay_msec(500)
	
	assert( http.get_status() == HTTPClient.STATUS_CONNECTED )
	
	var headers=[
		"User-Agent: Mozzila/1.0 (Godot)",
		"Accept: */*",
		"Connection: keep-alive",
		"Host: " + url[0]
	]
	
	var code = 0
	var tentativas = 0
	var dt = url[1]
	while code != 200:
		# fora se algo nao estiver certo
		tentativas += 1
		if tentativas > 2:
			call_deferred("bg_form_fail")
			return false
			
		err = http.request(HTTPClient.METHOD_GET,dt,headers)
		assert( err == OK )
		
		while (http.get_status() == HTTPClient.STATUS_REQUESTING):
			http.poll()
			print("Requesting..")
			OS.delay_msec(500)
		
		assert( http.get_status() == HTTPClient.STATUS_BODY or http.get_status() == HTTPClient.STATUS_CONNECTED )
		
		if (http.has_response()):
			var headers = http.get_response_headers_as_dictionary()
			code = http.get_response_code()
			print("code: ",http.get_response_code())
			
			if code==301:
				var location = headers.Location
				print("Location: ", location)
				if location.find("https://")>-1:
					location = location.substr(9,location.length()-8)
				else:
					location = location.substr(8,location.length()-7)
				var p = location.find("/")
				location = location.substr(p,location.length()-p)
				#print("Location: ", location)
				dt = location
		
	call_deferred("bg_form_done")
	return true

func bg_form_fail():
	pass

func bg_form_done():
	get_node("configuracoes/result").set_text("Dados recebidos")


const hexCD = ["0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F"]
const validURL = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 "

func toHex(cd):
	var a = (cd&0xf0) >> 4
	var b = cd&0x0f
	return "%" + hexCD[a] + hexCD[b]

func urlEncode(s):
	var ret = ""
	for i in range(s.length()):
		var c = s.substr(i,1)
		var cd = c.ord_at(0)
		if validURL.find(c)>-1:
			if c==" ":
				c = "+"
			ret += c
		else:
			ret += toHex(cd)
	return ret
	
func enviaForm():
	var nome = urlEncode( get_node("configuracoes/nome").get_text() )
	var email = urlEncode( get_node("configuracoes/email").get_text() )
	var site = urlEncode( get_node("configuracoes/site").get_text() )
	var opiniao = urlEncode( get_node("configuracoes/opiniao").get_text() )
	var uri = url_form[1]+"?nome="+nome+"&email="+email+"&site="+site+"&commentbody="+opiniao
	
	get_node("configuracoes/nome").hide()
	get_node("configuracoes/email").hide()
	get_node("configuracoes/site").hide()
	get_node("configuracoes/opiniao").hide()
	get_node("configuracoes/enviar").hide()
	get_node("configuracoes/result").show()
	get_node("configuracoes/result").set_text("Enviando...")
	
	sendForm.start( self, "bg_form", [url_form[0],uri] )

func _ready():
	playerDT = get_node("/root/playerdata")
	
	menuItens = []
	menuItens.push_back(get_node("menu/m1"))
	menuItens.push_back(get_node("menu/m2"))
	menuItens.push_back(get_node("menu/m3"))
	menuItens.push_back(get_node("menu/m4"))
	menuItens.push_back(get_node("menu/m5"))
	menuItens.push_back(get_node("menu/m6"))
	menuItens.push_back(get_node("menu/m7"))
	
	lastTela = get_node("menu")
	
	# procura updates se já nao fez isso
	if not playerDT.checkUpdateFeito:
		playerDT.checkUpdateFeito = true
		loadHTML.start(self,"bg_html", url_updates )
	
	# configuracoes?
	if not playerDT.configCarregado:
		carregaConfig()
		
	
	get_node("configuracoes/tocar_musicas").set_pressed(playerDT.tocarMusica)
	get_node("configuracoes/mostrar_fps").set_pressed(playerDT.isDebug)
	
	playerDT.detonade_tiles = []
	playerDT.inimigos_mortos = []
	playerDT.itens_coletados = []
	playerDT.segredos_coletados = []
	playerDT.cartas_coletadas = []
	playerDT.healt = 2
	playerDT.mana = 4
	
	if playerDT.abrir_estatisticas:
		lastTela.hide()
		tela = 1
		lastTela = get_node("estatisticas")
		calculeEstatisticas()
		lastTela.show()
		playerDT.abrir_estatisticas = false
	
	set_process(true)
	


# UI

func _on_tocar_musicas_toggled( pressed ):
	playerDT.tocarMusica = pressed
	saveConfig()
	print("tocar musica " + str(pressed))


func _on_mostrar_fps_toggled( pressed ):
	playerDT.isDebug = pressed
	saveConfig()
	print("debug " + str(pressed))


func _on_enviar_pressed():
	enviaForm()


func _on_voltar_pressed():
	item = 0
	tela = 0
	lastTela.hide()
	lastTela = get_node("menu")
	lastTela.show()
	


func _on_pag1_pressed():
	if OS.has_environment("%windir%"):
		OS.execute("C:\\Windows\\System32\\cmd.exe",["start","http://www.wildwitchproject.com/"],false)
	else:
		OS.execute("/usr/bin/x-www-browser",["http://www.wildwitchproject.com/"],false)


func _on_pag2_pressed():
	if OS.has_environment("%windir%"):
		OS.execute("C:\\Windows\\System32\\cmd.exe",["start","http://www.facebook.com/wildwitchproject"],false)
	else:
		OS.execute("/usr/bin/x-www-browser",["http://www.facebook.com/wildwitchproject"],false)

func _on_nome_text_changed():
	var nd = get_node("configuracoes/nome")
	if nd.get_text().find("\t")>-1:
		nd.set_text(nd.get_text().substr(0,nd.get_text().length()-1))
		get_node("configuracoes/email").grab_focus()

func _on_email_text_changed():
	var nd = get_node("configuracoes/email")
	if nd.get_text().find("\t")>-1:
		nd.set_text(nd.get_text().substr(0,nd.get_text().length()-1))
		get_node("configuracoes/site").grab_focus()

func _on_site_text_changed():
	var nd = get_node("configuracoes/site")
	if nd.get_text().find("\t")>-1:
		nd.set_text(nd.get_text().substr(0,nd.get_text().length()-1))
		get_node("configuracoes/opiniao").grab_focus()
