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

# ✅ controle de capítulos
var current_chapter = 1
var total_chapters = 2  # mude se tiver mais capítulos

# estatísticas do capítulo
var chapter_correct_answers = 0
var chapter_total_questions = 0

# controle de tutorial
var button_skip : Button
var skipped_tutorial = false
@onready var vbox_label_tutorial : VBoxContainer

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
var tutorial_index = 0
var highlight_rect : ColorRect
var tutorial_label = null
var tutorial_ongoing = true
var blocker: ColorRect = null

func _ready():
	# fade in
	var fade_rect := ColorRect.new()
	fade_rect.color = Color(0, 0, 0, 1)
	fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade_rect.z_index = 5
	add_child(fade_rect)

	start_chapter(current_chapter)

	$GameMusic.volume_db = -80
	$GameMusic.play()
	var tween = create_tween()
	tween.tween_property($GameMusic, "volume_db", 0, 0.5)
	var fade_tween := create_tween()
	fade_tween.tween_property(fade_rect, "color", Color(0, 0, 0, 0), 1.5)
	await fade_tween.finished
	fade_rect.queue_free()

	if current_chapter == 1:
		mostrar_tutorial_passo()

# 🚀 Inicia capítulo
func start_chapter(chapter: int):
	print("Iniciando capítulo ", chapter)
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
	deck = cards_data.keys()

func reset_indicators():
	pontosMoral.text = "20"
	pontosRecursos.text ="20"
	pontosTempo.text = "20"
	pontosProgresso.text = "20"
	pontosConfianca.text="20"
	chapter_correct_answers = 0
	chapter_total_questions = 0
	first_card = true

func spawn_new_card():
	if deck.size() == 0:
		show_summary()
		return 
	
	if current_card:
		current_card.queue_free()
	
	card_id = deck.pop_front()
	current_card = CardScene.instantiate()
	cardContainer.add_child(current_card)
	current_card.setup_card(cards_data[card_id])
	dilema.text = cards_data[card_id]["text"]
	dilema.add_theme_font_size_override("font_size", 21)
	current_card.connect("card_discarded", Callable(self, "_on_card_discarded"))
	
func set_points(node,direction,indicator):
	var points = cards_data[card_id][direction+"_effects"][indicator]
	node.text = str(node.text.to_int()+points)
	if(direction==cards_data[card_id]["correct_answer"] && points !=0 ):
		node.add_theme_color_override("font_color", Color.GREEN)
	if(direction!=cards_data[card_id]["correct_answer"] && points !=0 ):
		node.add_theme_color_override("font_color", Color.RED)
	await get_tree().create_timer(2).timeout
	node.add_theme_color_override("font_color", Color(1,1,1))

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
	await show_feedback_card(card_data,direction)
	if is_game_over():
		game_over()
		return
	first_card = false

# ✅ Mostra resumo e chama próximo capítulo
func show_summary():
	var percentage = 0
	if chapter_total_questions > 0:
		percentage = int(round(float(chapter_correct_answers) / chapter_total_questions * 100))
		
	var base_summary_text = "📜 Fim do Capítulo %d 📜\n\nVocê avançou na jornada da Agilidade." % current_chapter
	var percentage_text = "\n\nSua performance neste capítulo:\nVocê acertou %d%% das decisões!" % percentage
	var final_text = base_summary_text + percentage_text
	
	var summary_instance = SummaryScene.instantiate()
	summary_instance.texto_summary = final_text
	add_child(summary_instance)
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
	add_child(black_overlay)
	var tween := create_tween()
	tween.tween_property(black_overlay, "color", Color(0, 0, 0, 1), 1.0)
	await tween.finished
	for child in get_children():
		if child != black_overlay:
			child.queue_free()
	var game_over_sound = AudioStreamPlayer2D.new()
	game_over_sound.stream = load("res://assets/sounds/negative_beeps-6008.mp3")
	add_child(game_over_sound)
	game_over_sound.play()
	var center_container := CenterContainer.new()
	center_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center_container)
	var label := Label.new()
	label.text = "GAME OVER"
	label.add_theme_font_size_override("font_size", 64)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.modulate = Color(0, 0, 0, 0)
	var tween_label := create_tween()
	tween_label.tween_property(label, "modulate", Color(1, 1, 1, 1), 1.0)
	center_container.add_child(label)
	await get_tree().create_timer(5.0).timeout
	get_tree().reload_current_scene()


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
		highlight_rect.color = Color(0.3, 0.3, 0.3, 0.5)  
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
	var path = "res://scenes/transicao%d.tscn" % chapter
	var transicao_scene = load(path).instantiate()
	add_child(transicao_scene)
	
	# conecta para iniciar o capítulo quando a cena terminar
	transicao_scene.connect("transition_finished", Callable(self, "_on_transition_finished").bind(chapter))

func _on_transition_finished(chapter: int):
	start_chapter(chapter)
