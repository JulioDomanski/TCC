extends Control

@onready var btn_new_game = $TextureRect/CenterContainer/VBoxContainer/BtnNewGame
@onready var btn_continue =$TextureRect/CenterContainer/VBoxContainer/BtnContinue
@onready var btn_progress = $TextureRect/CenterContainer/VBoxContainer/BtnProgress
@onready var btn_sair = $TextureRect/CenterContainer/VBoxContainer/BtnSair
@onready var texture_rect = $TextureRect
@onready var title = $TextureRect/CenterContainer2/TitleGame
@onready var menu = $TextureRect/CenterContainer/VBoxContainer
@onready var sfx_intro = $SfxIntro 
@onready var confirmar = $ConfirmationDialog
@onready var progresso_menu = $TextureRect/CenterContainer/ScrollContainer
@onready var button_voltar_progresso = $ButtonVoltarProgresso
const SAVE_PATH := "user://savegame.json"
func _ready():
	# Inicialmente esconde tudo
	texture_rect.modulate.a = 0
	title.modulate.a = 0
	title.scale = Vector2(0.8, 0.8)
	menu.modulate.a = 0
	progresso_menu.visible = false
	button_voltar_progresso.visible = false
	

	# Conecta sinais
	btn_new_game.connect("pressed", Callable(self, "_on_new_game_pressed"))
	btn_continue.connect("pressed", Callable(self, "_on_continue_pressed"))
	btn_progress.connect("pressed", Callable(self, "_on_progress_pressed"))
	btn_sair.connect("pressed", Callable(self, "_on_exit_pressed"))
	if not FileAccess.file_exists("user://savegame.json"):
		btn_continue.disabled = true
	
	var tween = get_tree().create_tween()
	
	
	tween.tween_property(texture_rect, "modulate:a", 1, 3.0)
	
	
	tween.tween_interval(0.3) 
	tween.tween_callback(Callable(self, "_play_intro_sfx"))
	tween.tween_property(title, "modulate:a", 1, 1.5)
	tween.parallel().tween_property(title, "scale", Vector2(1, 1), 0.8).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	
	tween.tween_interval(0.5)
	tween.tween_property(menu, "modulate:a", 1, 1.5)
	
func _play_intro_sfx():
	if sfx_intro:
		sfx_intro.play()


func _on_new_game_pressed():
	# Reinicia o jogo do zero
	print("Novo Jogo iniciado!")
	if FileAccess.file_exists("user://savegame.json"):
		confirmar.popup_centered()
	
	else:
		get_tree().change_scene_to_file("res://scenes/Intro.tscn")

func _on_continue_pressed():
		get_tree().change_scene_to_file("res://scenes/Main.tscn")
		
	
		

func _on_progress_pressed():
	# Pode abrir uma tela de progresso, conquistas, capítulos desbloqueados etc
	print("Abrir tela de progresso")
	show_menu(0)
	progresso_menu.visible = true
	button_voltar_progresso.visible = true
	load_progress()
	
func _on_exit_pressed():
	get_tree().quit()

func delete_progression():
		var dir := DirAccess.open("user://")
		if dir:
			dir.remove("savegame.json")
		get_tree().change_scene_to_file("res://scenes/Intro.tscn")
	
# 0 para esconder , 1 para mostrar
func show_menu(num : int):
	menu.modulate.a = num
	title.modulate.a = num 

func load_progress():
	var array_titulos = ["Fundamentos da Agilidade","Ciclos de Reconstrução","O Conselho da Coroa","N/A","N/A","N/A"]
	var save_data = load_json()
	for i in range(1,7):
		var progress_card = preload("res://scenes/cardsProgresso.tscn").instantiate()
		setarCards(progress_card,save_data,i)
		$TextureRect/CenterContainer/ScrollContainer/HBoxContainer/CenterContainer/VBoxContainer2.add_child(progress_card)
			
		
			
			
			
		

func load_json():
	if not FileAccess.file_exists(SAVE_PATH):
		print("Nenhum save encontrado em", SAVE_PATH)
		return false
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var content = file.get_as_text()
	file.close()

	var save_data = JSON.parse_string(content)
	if typeof(save_data) != TYPE_DICTIONARY:
		print("❌ Erro: arquivo de save corrompido.")
		return false
	else :
		return save_data
		

func setarCards(progress_card : Node , save_data , i):
	var array_titulos = ["Fundamentos da Agilidade","Ciclos de Reconstrução","O Conselho da Coroa","N/A","N/A","N/A"]
	var title_cap = progress_card.get_node("Panel1/Cap1/HBoxContainer/Titulo")
	var porc_acerto = progress_card.get_node("Panel1/Cap1/HBoxContainer/Acerto")
	var pontos_moral = progress_card.get_node("Panel1/Cap1/HBoxContainer2/VBoxContainerMoral/Pontos")
	var pontos_recursos =  progress_card.get_node("Panel1/Cap1/HBoxContainer2/VBoxContainerRecursos/Pontos")
	var pontos_tempo = progress_card.get_node("Panel1/Cap1/HBoxContainer2/VBoxContainerTempo/Pontos")
	var pontos_progresso = progress_card.get_node("Panel1/Cap1/HBoxContainer2/VBoxContainerProgresso/Pontos")
	var pontos_confianca = progress_card.get_node("Panel1/Cap1/HBoxContainer2/VBoxContainerConfianca/Pontos")
	var png_moral = progress_card.get_node("Panel1/Cap1/HBoxContainer2/VBoxContainerMoral/Control/TextureRect")
	var png_recursos = progress_card.get_node("Panel1/Cap1/HBoxContainer2/VBoxContainerRecursos/Control/TextureRect")
	var png_tempo = progress_card.get_node("Panel1/Cap1/HBoxContainer2/VBoxContainerTempo/Control/TextureRect")
	var png_progresso = progress_card.get_node("Panel1/Cap1/HBoxContainer2/VBoxContainerProgresso/Control/TextureRect")
	var png_confianca = progress_card.get_node("Panel1/Cap1/HBoxContainer2/VBoxContainerConfianca/Control/TextureRect")
	if(!save_data):
		title_cap.text = "Capítulo "+ str(i) + ": ???????????" 
		porc_acerto.text = "Acerto : ??%"
		pontos_moral.text = "??"
		pontos_recursos.text = "??"
		pontos_tempo.text = "??"
		pontos_progresso.text = "??"
		pontos_confianca.text = "??"
		png_moral.modulate = Color(0.26,0.26,0,1.0)
		png_recursos.modulate = Color(0.26,0.26,0,1.0)
		png_tempo.modulate = Color(0.26,0.26,0,1.0)
		png_progresso.modulate = Color(0.26,0.26,0,1.0)
		png_confianca.modulate = Color(0.26,0.26,0,1.0)
			
	else:
			var capitulos = save_data.get("capitulos", {})
			title_cap.text = "Capítulo "+ str(i) + ": " + array_titulos[i-1]
			if(str(i) in capitulos):
				porc_acerto.text = "Acerto : "+capitulos.get(str(i)).get("percentual_acertos")+"%"
				pontos_moral.text = capitulos.get(str(i)).get("moral_final")
				pontos_recursos.text = capitulos.get(str(i)).get("recursos_final")
				pontos_tempo.text = capitulos.get(str(i)).get("tempo_final")
				pontos_progresso.text = capitulos.get(str(i)).get("progresso_final")
				pontos_confianca.text = capitulos.get(str(i)).get("confianca_final")
			else:
				title_cap.text = "Capítulo "+ str(i) + ": ???????????" 
				porc_acerto.text = "Acerto : ??%"
				pontos_moral.text = "??"
				pontos_recursos.text = "??"
				pontos_tempo.text = "??"
				pontos_progresso.text = "??"
				pontos_confianca.text = "??"
				png_moral.modulate = Color(0.26,0.26,0,1.0)
				png_recursos.modulate = Color(0.26,0.26,0,1.0)
				png_tempo.modulate = Color(0.26,0.26,0,1.0)
				png_progresso.modulate = Color(0.26,0.26,0,1.0)
				png_confianca.modulate = Color(0.26,0.26,0,1.0)
			

func voltar_menu():
	progresso_menu.visible = false
	button_voltar_progresso.visible = false
	for child in $TextureRect/CenterContainer/ScrollContainer/HBoxContainer/CenterContainer/VBoxContainer2.get_children():
		if child is not Label:
			child.queue_free()
	show_menu(1)
	
