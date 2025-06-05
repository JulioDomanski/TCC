extends Control

const CardScene = preload("res://scenes/Card.tscn")

var deck = [] # Array com os IDs das cartas
var current_card = null
var cards_data = {}
var feedback_data = {}
var card_id = 0 # Dicionário para armazenar todas as cartas
var showing_feedback = false
var first_card = true
@onready var pontosMoral = $MiddleControl/WrapperIndicadores/PontosMoral
@onready var pontosTempo = $MiddleControl/WrapperIndicadores/PontosTempo
@onready var pontosRecursos = $MiddleControl/WrapperIndicadores/PontosRecursos
@onready var pontosProgresso = $MiddleControl/WrapperIndicadores/PontosProgresso
@onready var pontosConfianca = $MiddleControl/WrapperIndicadores/PontosConfianca
@onready var cardContainer = $MiddleControl/CardContainer
@onready var dilema = $MiddleControl/CardContainer/Dilema

func _ready():
	load_cards_data()
	initialize_deck()
	spawn_new_card()
	pontosMoral.text = "3"
	pontosRecursos.text ="5"
	pontosTempo.text = "5"
	pontosProgresso.text = "0"
	pontosConfianca.text="4"
	

func load_cards_data():
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
	for card in result:
		if card.has("id"):
			cards_data[card["id"]] = card


func initialize_deck():
	# Cria um deck com todos os IDs disponíveis
	deck = cards_data.keys()

func spawn_new_card():
	# Verifica se tem cartas no deck
	if deck.size() == 0:
		initialize_deck() # Recarrega se acabou
	
	# Remove a carta atual se existir
	if current_card:
		current_card.queue_free()
	
	# Pega o ID da próxima carta
	card_id = deck.pop_front()
	print("Carta atual - ID: ", card_id)
	
	# Cria a nova carta
	current_card = CardScene.instantiate()
	cardContainer.add_child(current_card)
	
	
	# Configura a carta com os dados do JSON
	current_card.setup_card(cards_data[card_id])
	dilema.text = cards_data[card_id]["text"]
	
	# Conecta o sinal para saber quando a carta foi descartada
	current_card.connect("card_discarded", Callable(self, "_on_card_discarded"))
	
func set_points(node,direction,indicator):
	var points = cards_data[card_id][direction+"_effects"][indicator]
	node.text = str(node.text.to_int()+points)
	if(direction==cards_data[card_id]["correct_answer"] && points !=0 ):
		node.add_theme_color_override("font_color", Color(0, 1, 0))
	if(direction!=cards_data[card_id]["correct_answer"] && points !=0 ):
		node.add_theme_color_override("font_color", Color(1, 0, 0))
	await get_tree().create_timer(0.5).timeout
	node.add_theme_color_override("font_color", Color(1,1,1))
	
func show_feedback_card(card_data,direction) -> Signal:
	showing_feedback = true
	
	# Remove decision card
	if current_card:
		current_card.queue_free()
	
	# Create feedback card
	current_card = CardScene.instantiate()
	cardContainer.add_child(current_card)
	current_card.setup_card(cards_data[card_id], true,direction)
	current_card.connect("card_discarded", Callable(self, "_on_card_discarded"))
	return current_card.card_discarded  # Wait until card is swiped
		
func _on_card_discarded(direction, card_data):
	
	if is_game_over():
		game_over()
		return
	
	
	if showing_feedback:
		# Feedback was shown and swiped away, now show next card
		showing_feedback = false
		spawn_new_card()
		return
	
	print(cards_data[card_id][direction+"_effects"])	
	set_points(pontosMoral,direction,"moral")
	set_points(pontosRecursos,direction,"resources")
	set_points(pontosProgresso,direction,"progress")
	set_points(pontosTempo,direction,"time")
	set_points(pontosConfianca,direction,"trust")
		
	print("Carta descartada: ", direction)
	# Aqui você pode processar os efeitos da carta se quiser
	
	
	
		
	await show_feedback_card(card_data,direction)# Pede uma nova carta
	print(is_game_over())
	first_card = false
	
func is_game_over():
	if(first_card == false and (pontosConfianca.text.to_int()<=0 or pontosProgresso.text.to_int()<=0 or pontosTempo.text.to_int()<=0 or pontosRecursos.text.to_int()<=0 or pontosMoral.text.to_int()<=0)):
		return true;
	return false;
	
func game_over():
	

	# Step 1: Create full-screen black overlay
	var black_overlay := ColorRect.new()
	black_overlay.color = Color(0, 0, 0, 0)  # Fully transparent
	black_overlay.anchor_left = 0
	black_overlay.anchor_top = 0
	black_overlay.anchor_right = 1
	black_overlay.anchor_bottom = 1
	black_overlay.offset_left = 0
	black_overlay.offset_top = 0
	black_overlay.offset_right = 0
	black_overlay.offset_bottom = 0
	add_child(black_overlay)

	# Step 2: Tween fade to black
	var tween := create_tween()
	tween.tween_property(black_overlay, "color", Color(0, 0, 0, 1), 1.0)
	await tween.finished

	# Step 3: Remove all children except the overlay
	for child in get_children():
		if child != black_overlay:
			child.queue_free()
	
	
	await get_tree().process_frame  # Let Godot finish cleanup
	'''
	# Step 4: Add centered "GAME OVER" label
	var label := Label.new()
	label.text = "GAME OVER"
	
	var center = get_viewport().get_visible_rect().size / 2
	print(center)

	# Set offsets to center it exactly (if size is known/fixed)
	label.offset_left = 100
	label.offset_top = 100
	label.offset_right = 200
	label.offset_bottom = 200 

	# OR: leave offsets at 0 and enable center alignment
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	# Customize appearance
	label.add_theme_font_size_override("font_size", 64)
	label.modulate = Color(0, 0, 0, 0)

	# Fade in effect
	var tween_label := create_tween()
	tween_label.tween_property(label, "modulate", Color(1, 1, 1, 1), 1.0)
	black_overlay.add_child(label)
	'''
	# In _ready or a function:
	var center_container := CenterContainer.new()
	center_container.anchor_left = 0
	center_container.anchor_top = 0
	center_container.anchor_right = 1
	center_container.anchor_bottom = 1
	center_container.offset_left = 0
	center_container.offset_top = 0
	center_container.offset_right = 0
	center_container.offset_bottom = 0
	add_child(center_container)

	var label := Label.new()
	label.text = "GAME OVER"
	label.add_theme_font_size_override("font_size", 64)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	# Customize appearance
	label.add_theme_font_size_override("font_size", 64)
	label.modulate = Color(0, 0, 0, 0)

	# Fade in effect
	var tween_label := create_tween()
	tween_label.tween_property(label, "modulate", Color(1, 1, 1, 1), 1.0)

	center_container.add_child(label)

		
