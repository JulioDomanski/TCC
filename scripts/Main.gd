extends Control

const CardScene = preload("res://scenes/Card.tscn")
var SummaryScene = preload("res://scenes/SummaryCap.tscn")

var deck = [] 
var current_card = null
var cards_data = {}
var card_id = 0
var showing_feedback = false
var first_card = true
var is_tutorial_busy := false
var rect_fade: ColorRect

var caos_tutorial_shown := false

# ✅ controle de capítulos
var current_chapter = 1
var total_chapters = 3  # mude se tiver mais capítulos

# estatísticas do capítulo
var chapter_correct_answers = 0
var chapter_total_questions = 0

# controle de tutorial
var button_skip : Button
var skipped_tutorial = false
@onready var vbox_label_tutorial : VBoxContainer
# timer chaos_escopial
var chaos_timer_label: Label = null

var moral_save =0;
var recursos_save =0; 
var tempo_save =0; 
var progresso_save =0; 
var confianca_save =0; 


# indicadores
@onready var backIndicadores = $MiddleControl/WrapperIndicadores/BackIndicadores
@onready var pontosMoral = $MiddleControl/WrapperIndicadores/BackIndicadores/PontosMoral
@onready var pontosTempo = $MiddleControl/WrapperIndicadores/BackIndicadores/PontosTempo
@onready var pontosRecursos = $MiddleControl/WrapperIndicadores/BackIndicadores/PontosRecursos
@onready var pontosProgresso = $MiddleControl/WrapperIndicadores/BackIndicadores/PontosProgresso
@onready var pontosConfianca = $MiddleControl/WrapperIndicadores/BackIndicadores/PontosConfianca
@onready var cardContainer = $MiddleControl/CardContainer
@onready var dilema = $MiddleControl/CardContainer/Dilema
@onready var ui = $"UI"
@onready var viewport = get_viewport_rect()


# tutorial
var tutorial_passos = [
	{"mensagem": "Bem-vindo, jovem herdeiro! Chegou a hora de conhecer os pilares do seu reinado. Clique para continuar."},
	{"mensagem": "Vamos te mostrar agora os indicadores e mecânicas essenciais. Preste atenção!"},
	{"target_node_path": "MiddleControl/WrapperIndicadores/BackIndicadores/IndicadorMoral","mensagem": "Este é o indicador de Moral dos anões. Tome decisões estratégicas para mantê-lo alto!"},
	{"target_node_path": "MiddleControl/WrapperIndicadores/BackIndicadores/IndicadorRecursos","mensagem": "Aqui está o Tesouro do reino. Cuidado para não levar o reino à falência!"},
	{"target_node_path": "MiddleControl/WrapperIndicadores/BackIndicadores/InidicadotTempo","mensagem": "Este é o indicador de Tempo. Suas ações consomem ciclos — pense com sabedoria!"},
	{"target_node_path": "MiddleControl/WrapperIndicadores/BackIndicadores/IndicadorProgresso","mensagem": "Este é o Progresso do castelo. Construa o reino tijolo por tijolo!"},
	{"target_node_path": "MiddleControl/WrapperIndicadores/BackIndicadores/IndicadorConfianca","mensagem": "Este é o indicador da confiança da Rainha Stakeholdina. Conquistar sua aprovação é vital!"},
	{"target_node_path": "MiddleControl/CardContainer/Dilema","mensagem": "Aqui é onde os dilemas são apresentados. Cada decisão molda o futuro do reino."},
	{"target_node_path": "Card","mensagem": "Esta é a carta de decisão. Arraste para a direita ou esquerda para escolher."},
	{"mensagem": "Se qualquer indicador chegar a zero, o reinado entra em colapso... Game Over!"},
	{"mensagem": "Você está pronto! Boa sorte, e que sua liderança traga prosperidade ao reino!"}
]

# Array com os textos finais e temáticos para o sumário de cada capítulo.
var chapter_summary_bodies = [
	"", # Placeholder para o índice 0
	
	# Capítulo 1: Fundamentos da Agilidade
	"Neste capítulo, você aprendeu sobre:\n\n" +
	"- Adaptação sobre Planos Rígidos\n" +
	"- Colaboração e Transparência\n" +
	"- Foco em Entregas de Valor\n" +
	"- Melhoria Contínua",
	
	# Capítulo 2: O Ritmo dos Sprints
	"Neste capítulo, você aprendeu sobre:\n\n" +
	"- O Poder dos Sprints (Ciclos Curtos)\n" +
	"- Foco no Objetivo de Cada Ciclo\n" +
	"- Entregas Incrementais e Revisão\n" +
	"- A Importância de Proteger o Foco",
	
	# Capítulo 3: Os Papéis do Time Scrum
	"Neste capítulo, você aprendeu sobre:\n\n" +
	"- Priorização de Valor (Product Owner)\n" +
	"- Facilitação e Proteção (Scrum Master)\n" +
	"- Auto-organização e Execução (Time)\n" +
	"- A Força dos Papéis Bem Definidos"
]

var tutorial_index = 0
var highlight_rect : ColorRect
var tutorial_label = null
var tutorial_ongoing = true
var blocker: ColorRect = null

# Timer
var decision_time := 20   # segundos por carta
var time_left := 0
@onready var timer_label := Label.new()
var timer_node : Timer

func _ready():
	# fade in
	var fade_rect := ColorRect.new()
	fade_rect.color = Color(0, 0, 0, 1)
	fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade_rect.z_index = 5
	add_child(fade_rect)
	load_game()
	

	start_chapter(current_chapter)

	$GameMusic.volume_db = -80
	$GameMusic.play()
	var tween = create_tween()
	tween.tween_property($GameMusic, "volume_db", 0, 0.5)
	var fade_tween := create_tween()
	fade_tween.tween_property(fade_rect, "color", Color(0, 0, 0, 0), 1.5)
	await fade_tween.finished
	fade_rect.queue_free()

	# --- ADICIONE ESTE CÓDIGO PARA INICIALIZAR O rect_fade ---
	if(current_chapter ==1):
		rect_fade = ColorRect.new()
		rect_fade.color = Color.BLACK
		rect_fade.set_anchors_preset(Control.PRESET_FULL_RECT)
		rect_fade.z_index = 50
		rect_fade.modulate.a = 0.0  # Começa transparente
		rect_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(rect_fade)
	# --------------------------------------------------------

	if current_chapter == 1:
		mostrar_tutorial_passo()
		
	
	

# 🚀 Inicia capítulo
func start_chapter(chapter: int):
	print("Iniciando capítulo ", chapter)
	if(current_chapter!=1):
		change_bg_chapter()
	load_cards_data(chapter)
	initialize_deck()
	reset_indicators()
	spawn_new_card()

func load_cards_data(chapter: int):
	var file = FileAccess.open("res://data/cards.json", FileAccess.READ)
	if file == null:
		push_error("Arquivo cards.json não encontrado!")
		return
	
	var json_data = file.get_as_text()
	file.close()
	var test_json_conv = JSON.new()
	var error = test_json_conv.parse(json_data)
	if error != OK:
		push_error("Erro ao analisar JSON!")
		return
	
	var result = test_json_conv.get_data()
	cards_data.clear()
	if result.has("capitulo_%d" % chapter):
		for card in result["capitulo_%d" % chapter]:
			cards_data[card["id"]] = card
	else:
		push_error("Capítulo %d não encontrado no JSON!" % chapter)

func initialize_deck():
	var keys = cards_data.keys()
	# para fins de testes : deck = keys.slice(0, 3)
	deck = keys 
	

func reset_indicators():
	pontosMoral.text = "20"
	moral_save=pontosMoral.text
	pontosRecursos.text ="20"
	recursos_save=pontosRecursos.text
	pontosTempo.text = "20"
	tempo_save=pontosTempo.text
	pontosProgresso.text = "20"
	progresso_save= pontosProgresso.text
	pontosConfianca.text="20"
	confianca_save= pontosConfianca.text
	chapter_correct_answers = 0
	chapter_total_questions = 0
	first_card = true

func spawn_new_card():
	if deck.size() == 0:
		if is_game_over():
			return
		show_summary()
		return 
	
	# Remove previous card
	if current_card:
		if cards_data[card_id]["image"] == "Caos Escopial":
			dilema.add_theme_color_override("font_color", Color(1,1,1))
		current_card.queue_free()

	card_id = deck.pop_front()
	current_card = CardScene.instantiate()
	cardContainer.add_child(current_card)
	current_card.setup_card(cards_data[card_id])

	# Special case: Caos Escopial
	if cards_data[card_id]["image"] == "Caos Escopial" and not showing_feedback:
		dilema.add_theme_color_override("font_color", Color(1, 1, 1))
		if not caos_tutorial_shown:
			caos_tutorial_shown = true
			await tutorial_caos_escopial()

		# Create chaos timer label
		chaos_timer_label = Label.new()
		chaos_timer_label.text = str(decision_time)
		chaos_timer_label.add_theme_font_size_override("font_size", 28)
		chaos_timer_label.set("custom_colors/font_color", Color(1, 0, 0))
		chaos_timer_label.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
		chaos_timer_label.z_index = 20
		cardContainer.add_child(chaos_timer_label)

		# Create timer
		var chaos_timer = Timer.new()
		chaos_timer.wait_time = 1.0
		chaos_timer.one_shot = false
		chaos_timer.connect("timeout", Callable(self, "_on_chaos_timer_tick").bind(chaos_timer_label, chaos_timer))
		current_card.add_child(chaos_timer)
		chaos_timer.start()
	
	# Normal card setup
	dilema.text = cards_data[card_id]["text"]
	dilema.add_theme_font_size_override("font_size", 21)
	dilema.show()
	current_card.connect("card_discarded", Callable(self, "_on_card_discarded"))

	
	
func set_points(node, direction, indicator):
	var points = cards_data[card_id][direction+"_effects"][indicator]
	node.text = str(node.text.to_int() + points)
	save_points(node);
	if direction == cards_data[card_id]["correct_answer"] && points != 0:
		node.add_theme_color_override("font_color", Color.GREEN)
		glow_indicators(indicator  , true)
		
	if direction != cards_data[card_id]["correct_answer"] && points != 0:
		node.add_theme_color_override("font_color", Color.RED)
		glow_indicators(indicator , false)
	
	
	
	await get_tree().create_timer(2).timeout
	
	# ✅ VERIFICAR se o nó ainda existe antes de modificar
	if is_instance_valid(node):
		node.add_theme_color_override("font_color", Color(1, 1, 1))

func show_feedback_card(card_data,direction) -> Signal:
	showing_feedback = true
	if current_card:
		current_card.queue_free()
	current_card = CardScene.instantiate()
	cardContainer.add_child(current_card)
	current_card.setup_card(cards_data[card_id], true,direction)
	current_card.connect("card_discarded", Callable(self, "_on_card_discarded"))
	return current_card.card_discarded  
		
func _on_card_discarded(direction, card_data):
	if showing_feedback:
		showing_feedback = false
		if is_game_over():
			game_over()
			return
		spawn_new_card()
		return
	chapter_total_questions += 1
	if direction == cards_data[card_id]["correct_answer"]:
		chapter_correct_answers += 1
	set_points(pontosMoral,direction,"moral")
	set_points(pontosRecursos,direction,"resources")
	set_points(pontosProgresso,direction,"progress")
	set_points(pontosTempo,direction,"time")
	set_points(pontosConfianca,direction,"trust")
	if chaos_timer_label:
		chaos_timer_label.queue_free()
		chaos_timer_label = null
	await show_feedback_card(card_data,direction)
	first_card = false

func show_summary():
	dilema.hide()
	var percentage = 0
	if chapter_total_questions > 0:
		percentage = int(round(float(chapter_correct_answers) / chapter_total_questions * 100))
		
	var title_text = "Fim do Capítulo %d" % current_chapter
	

	var body_text = "" 
	if current_chapter < chapter_summary_bodies.size():
		body_text = chapter_summary_bodies[current_chapter]
	else:
		body_text = "Você avançou na jornada da Agilidade."

	var result_text = "Sua performance: %d%% de acerto!" % percentage
	save_game_fim_capitulo(str(percentage))
	var summary_instance = SummaryScene.instantiate()
	add_child(summary_instance)
	
	summary_instance.set_summary_texts(title_text, body_text, result_text)
	
	summary_instance.popup_centered() 
	
	summary_instance.connect("popup_hide", Callable(self, "_on_summary_closed"))

func _on_summary_closed():
	current_chapter += 1
	if current_chapter <= total_chapters:
		cena_transicao(current_chapter)
	else:
		dilema.text = "🏆 Parabéns! Você concluiu a jornada da reconstrução do reino."

func is_game_over():
	if(first_card == false and (pontosConfianca.text.to_int()<=0 or pontosProgresso.text.to_int()<=0 or pontosTempo.text.to_int()<=0 or pontosRecursos.text.to_int()<=0 or pontosMoral.text.to_int()<=0)):
		return true;
	return false;
	
func game_over():
	var black_overlay := ColorRect.new()
	black_overlay.color = Color(0, 0, 0, 0)  
	black_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	black_overlay.z_index =50
	add_child(black_overlay)
	var tween := create_tween()
	tween.tween_property(black_overlay, "color", Color(0, 0, 0, 1), 1.0)
	await tween.finished
	if chaos_timer_label:
		chaos_timer_label.queue_free()
		chaos_timer_label = null
	var game_over_sound = AudioStreamPlayer2D.new()
	game_over_sound.stream = load("res://assets/sounds/negative_beeps-6008.mp3")
	add_child(game_over_sound)
	game_over_sound.play()
	var center_container := CenterContainer.new()
	center_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	center_container.z_index = 51
	add_child(center_container)
	var label := Label.new()
	label.text = "GAME OVER"
	label.add_theme_font_size_override("font_size", 64)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.modulate = Color(0, 0, 0, 0)
	label.z_index = 51
	var tween_label := create_tween()
	tween_label.tween_property(label, "modulate", Color(1, 1, 1, 1), 1.0)
	center_container.add_child(label)
	await get_tree().create_timer(6).timeout
	var tween_out := create_tween()
	tween_out.tween_property(black_overlay, "color", Color(0, 0, 0, 0), 1.0)
	tween_out.tween_property(label, "modulate", Color(0, 0, 0, 0), 1.0)
	start_chapter(current_chapter)
	await tween_out.finished
	black_overlay.queue_free()
	center_container.queue_free()
	game_over_sound.queue_free()
	
	


func mostrar_tutorial_passo() -> void:
	if is_tutorial_busy:
		tutorial_index -=1
		return
	is_tutorial_busy = true
	if tutorial_index >= tutorial_passos.size():
		var fade_out_tween = create_tween()
		fade_out_tween.tween_property(tutorial_label, "modulate:a", 0.0, 0.5)
		await fade_out_tween.finished
		tutorial_label.queue_free()
		return

	var passo = tutorial_passos[tutorial_index]
	var target_node
	
	
	var tween_tutorial_fade_out = create_tween()

	if highlight_rect:
		tween_tutorial_fade_out.tween_property(highlight_rect, "modulate:a", 0.0, 0.5)
		await tween_tutorial_fade_out.finished
		if(is_instance_valid(highlight_rect)):
			highlight_rect.queue_free()

	if passo.has("target_node_path") and passo["target_node_path"] != null:
		if(passo["target_node_path"] == "Card"):
			target_node = current_card.get_child(0,false)
		
	
		else:
			target_node = get_node(passo["target_node_path"])
		highlight_rect = ColorRect.new()
		highlight_rect.color = Color(1, 1, 0, 0.4)  
		highlight_rect.modulate = Color(1, 1, 1, 0)       
		highlight_rect.anchor_left = target_node.anchor_left
		highlight_rect.anchor_top = target_node.anchor_top
		if(passo["target_node_path"].contains("BackIndicadores")):
			highlight_rect.anchor_bottom = target_node.anchor_bottom+0.1
			highlight_rect.offset_bottom = target_node.offset_bottom+0.1
		else:
			highlight_rect.anchor_bottom = target_node.anchor_bottom
			highlight_rect.offset_bottom = target_node.offset_bottom
		highlight_rect.anchor_right = target_node.anchor_right
		highlight_rect.offset_left = target_node.offset_left
		highlight_rect.offset_top = target_node.offset_top
		highlight_rect.offset_right = target_node.offset_right
		
		highlight_rect.z_index = 10

		target_node.get_parent().add_child(highlight_rect)

	
		var tween_highlight_rect = create_tween()
		tween_highlight_rect.tween_property(highlight_rect, "modulate:a", 1.0, 0.5)
		await tween_highlight_rect.finished
	
	
	
	
	
	if tutorial_label:
		var fade_out_tween = create_tween()
		fade_out_tween.tween_property(tutorial_label, "modulate:a", 0.0, 0.5)
		await fade_out_tween.finished
		if(is_instance_valid(tutorial_label)):
			tutorial_label.queue_free()

	
	tutorial_label = Label.new()
	tutorial_label.text = passo["mensagem"]

	
	tutorial_label.anchor_left = 0.1
	tutorial_label.anchor_right = 0.9
	tutorial_label.anchor_top = 0.9
	tutorial_label.anchor_bottom = 1.0
	tutorial_label.offset_left = 0
	tutorial_label.offset_right = 0
	tutorial_label.offset_top = -40
	tutorial_label.offset_bottom = -10

	
	tutorial_label.add_theme_font_size_override("font_size", 22)
	tutorial_label.set("custom_colors/font_color", Color(1, 1, 1))
	tutorial_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tutorial_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	
	tutorial_label.modulate = Color(1, 1, 1, 0)
	add_child(tutorial_label)

	var fade_in_tween = create_tween()
	fade_in_tween.tween_property(tutorial_label, "modulate:a", 1.0, 0.5)
	await fade_in_tween.finished
	is_tutorial_busy = false
	
func _input(event):
	
	if get_tree().paused:
		return
		
	if event is InputEventMouseButton and event.pressed:
		# Se clicou no botão de pular, não faz mais nada aqui
		if button_skip and button_skip.get_global_rect().has_point(event.position):
			return

		if tutorial_index <= tutorial_passos.size() - 1:
			if tutorial_index == 0:
				var card = cardContainer.get_child(1, false).get_child(0, true)
				blocker = ColorRect.new()
				blocker.color = Color(0, 0, 0, 0)
				blocker.mouse_filter = MOUSE_FILTER_STOP
				blocker.size = card.size
				blocker.anchor_bottom = card.anchor_bottom
				blocker.anchor_left = card.anchor_left
				blocker.anchor_right = card.anchor_right
				blocker.anchor_top = card.anchor_top
				blocker.offset_bottom = card.offset_bottom
				blocker.offset_left = card.offset_left
				blocker.offset_right = card.offset_right
				blocker.offset_top = card.offset_top
				add_child(blocker)

				button_skip = Button.new()
				button_skip.text = "Pular Tutorial"
				button_skip.custom_minimum_size = Vector2(150, 50)
				button_skip.add_theme_font_size_override("font_size", 22)
				button_skip.modulate = Color(1, 1, 1, 1)
				button_skip.z_index = 3
				add_child(button_skip)

				button_skip.anchor_left = 1
				button_skip.anchor_top = 1
				button_skip.anchor_right = 1
				button_skip.anchor_bottom = 1
				button_skip.offset_right = -30
				button_skip.offset_bottom = -30
				button_skip.offset_left = -210
				button_skip.offset_top = -50
				button_skip.pressed.connect(pular_tutorial)

			if skipped_tutorial:
				return

			tutorial_index += 1
			await mostrar_tutorial_passo()
			print(tutorial_index)

	if tutorial_index == 11:
		blocker.mouse_filter = MOUSE_FILTER_IGNORE
		blocker.queue_free()
		if button_skip and is_instance_valid(button_skip):
			button_skip.queue_free()
		tutorial_index += 1
		
		
	
		
func pular_tutorial():
	skipped_tutorial = true
	if highlight_rect and is_instance_valid(highlight_rect):
		highlight_rect.queue_free()

	if tutorial_label and is_instance_valid(tutorial_label):
		tutorial_label.text = ""
		tutorial_label.queue_free()

	if blocker and is_instance_valid(blocker):
		blocker.queue_free()

	if button_skip and is_instance_valid(button_skip):
		button_skip.queue_free()

	is_tutorial_busy = false
	tutorial_index = tutorial_passos.size() + 1  
	print(tutorial_passos.size() + 1)

func cena_transicao(chapter: int):
	var instant_fade = ColorRect.new()
	instant_fade.color = Color.BLACK
	instant_fade.modulate.a = 1.0 
	instant_fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	instant_fade.z_index = 60 
	add_child(instant_fade)
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	var path = "res://scenes/transicao%d.tscn" % chapter
	var transicao_scene = load(path).instantiate()
	transicao_scene.z_index = 45
	add_child(transicao_scene)
	
	# Remover o instant_fade com fade
	var fade_out_tween = create_tween()
	fade_out_tween.tween_property(instant_fade, "modulate:a", 0.0, 0.3)
	await fade_out_tween.finished
	instant_fade.queue_free()
	
	# Conectar o sinal
	transicao_scene.connect(
		"transition_finished",
		Callable(self, "_on_transition_finished").bind(chapter, transicao_scene)
	)

func _on_transition_finished(chapter: int, transicao_scene):
	var instant_fade = ColorRect.new()
	instant_fade.color = Color.BLACK
	instant_fade.modulate.a = 1.0  
	instant_fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	instant_fade.z_index = 60 
	add_child(instant_fade)
	
	# Múltiplas pausas para garantir renderização
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	
	if is_instance_valid(transicao_scene):
		transicao_scene.queue_free()
	
	start_chapter(chapter)
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	var fade_in_tween = create_tween()
	fade_in_tween.tween_property(instant_fade, "modulate:a", 0.0, 0.8)
	await fade_in_tween.finished
	instant_fade.queue_free()

func start_decision_timer():
	time_left = decision_time
	timer_label.text = str(time_left)
	timer_node.start()

func _on_chaos_timer_tick(timer_label: Label, timer_node: Timer):
	var time_left = timer_label.text.to_int() - 1
	if(time_left ==5):
		timer_label.add_theme_color_override("font_color", Color(1,0,0))
	timer_label.text = str(time_left)
	if time_left <= 0:
		timer_node.stop()
		_on_time_expired()  # Game Over

func _on_time_expired():
	# Decide penalidade automática
	print("⏰ Tempo esgotado!")
	game_over()

#funcao para mudar o fundo por capitulo
func change_bg_chapter():
	var path = "res://assets/backgrounds/Bg Cap %d.png" % current_chapter
	$UI/Background.texture = load(path)


func pulse_glow(icon: Node , correct : bool):
	var tween = get_tree().create_tween()
	for i in range(2):
		# Fade
		if(correct):
			tween.tween_property(icon, "modulate", Color(0, 1, 0, 0.6), 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		else:
			tween.tween_property(icon, "modulate", Color(1,0 , 0, 0.6), 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(icon, "modulate", Color(1, 1, 1, 1), 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		
		# Scale
		tween.tween_property(icon, "scale", Vector2(1 , 0.5), 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(icon, "scale", Vector2(1, 1), 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func glow_indicators(indicator : String , correct : bool):
	if(indicator == 'moral'):
			pulse_glow($MiddleControl/WrapperIndicadores/BackIndicadores/IndicadorMoral , correct)
	elif(indicator == 'resources'):
			pulse_glow($MiddleControl/WrapperIndicadores/BackIndicadores/IndicadorRecursos , correct)
	elif (indicator == 'progress'):
			pulse_glow($MiddleControl/WrapperIndicadores/BackIndicadores/IndicadorProgresso , correct)
	elif (indicator == "time"):
			pulse_glow($MiddleControl/WrapperIndicadores/BackIndicadores/InidicadotTempo , correct)
	elif(indicator == "trust"):
			pulse_glow($MiddleControl/WrapperIndicadores/BackIndicadores/IndicadorConfianca , correct)


func highlight_icon(icon: TextureRect, correct: bool):
	var tween = get_tree().create_tween()
	if correct:
		tween.tween_property(icon, "modulate", Color(0, 1, 0), 0.3)  # green
	else:
		tween.tween_property(icon, "modulate", Color(1, 0, 0), 0.3)  # red
	
	# fade back to normal after 1s
	tween.tween_property(icon, "modulate", Color(1, 1, 1), 0.8)

func tutorial_caos_escopial():
	var tutorial_label = Label.new()
	tutorial_label.text = "⚡Um Caos Escopial surgiu! ⚡\n\nVocê tem pouco tempo para decidir!\nArraste rapidamente para escolher sua resposta.\nSe não agir antes do fim do tempo, será Game Over!"
	tutorial_label.anchor_left = 0.1
	tutorial_label.anchor_right = 0.9
	tutorial_label.anchor_top = 0.9
	tutorial_label.anchor_bottom = 1.0
	tutorial_label.offset_left = 0
	tutorial_label.offset_right = 0
	tutorial_label.offset_top = -80
	tutorial_label.offset_bottom = -20
	tutorial_label.add_theme_font_size_override("font_size", 22)
	tutorial_label.set("custom_colors/font_color", Color(1, 0.3, 0.3))
	tutorial_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tutorial_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tutorial_label.z_index = 100
	tutorial_label.modulate.a = 0.0
	add_child(tutorial_label)
	
	# Fade in/out effect
	var tween = create_tween()
	tween.tween_property(tutorial_label, "modulate:a", 1.0, 1.0)
	tween.tween_interval(6) # stays visible
	tween.tween_property(tutorial_label, "modulate:a", 0.0, 0.5)

	await tween.finished
	if is_instance_valid(tutorial_label):
		tutorial_label.queue_free()
const SAVE_PATH := "user://savegame.json"

func save_game_fim_capitulo(porcentagem_acertos: String):
	var save_data = {}
	
	# Check if file exists — to preserve previous chapters
	if FileAccess.file_exists(SAVE_PATH):
		var file_read = FileAccess.open(SAVE_PATH, FileAccess.READ)
		save_data = JSON.parse_string(file_read.get_as_text())
		file_read.close()
	
	if typeof(save_data) != TYPE_DICTIONARY:
		save_data = {}
	
	# Make sure the chapter history exists
	if not save_data.has("capitulos"):
		save_data["capitulos"] = {}

	# Save current chapter stats
	save_data["capitulos"][str(current_chapter)] = {
		"moral_final": moral_save,
		"recursos_final": recursos_save,
		"tempo_final": tempo_save,
		"progresso_final": progresso_save,
		"confianca_final": confianca_save,
		"percentual_acertos": porcentagem_acertos
	}

	# Also keep global progress info
	save_data["capitulo_atual"] = current_chapter+1
	save_data["tutorial_concluido"] = skipped_tutorial
	save_data["carta_atual"] = card_id

	# Write back to file
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data, "\t"))
	file.close()

	print("✅ Progresso do capítulo", current_chapter, "salvo com sucesso!")



func save_points(node : Node):
	if "Moral" in node.name:
		moral_save=node.text
	elif "Confianca" in node.name:
		confianca_save=node.text
	elif "Progresso" in node.name:
		progresso_save=node.text
	elif "Tempo" in node.name:
		tempo_save=node.text
	elif "Recursos" in node.name:
		recursos_save=node.text


func load_game():
	if not FileAccess.file_exists(SAVE_PATH):
		print("Nenhum save encontrado em", SAVE_PATH)
		return null
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var content = file.get_as_text()
	file.close()

	var save_data = JSON.parse_string(content)
	if typeof(save_data) != TYPE_DICTIONARY:
		print("❌ Erro: arquivo de save corrompido.")
		return null

	# --- Recuperar dados principais ---
	current_chapter = int(save_data.get("capitulo_atual", 1))
	skipped_tutorial = save_data.get("tutorial_concluido", false)
	tutorial_index=20
	card_id = save_data.get("carta_atual", "")
