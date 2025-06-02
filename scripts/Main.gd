extends Control

const CardScene = preload("res://scenes/Card.tscn")

var deck = [] # Array com os IDs das cartas
var current_card = null
var cards_data = {}
var feedback_data = {}
var card_id = 0 # Dicionário para armazenar todas as cartas
var showing_feedback = false
var first_card = true
func _ready():
	load_cards_data()
	initialize_deck()
	spawn_new_card()
	$WrapperIndicadores/PontosMoral.text = "3"
	$WrapperIndicadores/PontosRecursos.text ="5"
	$WrapperIndicadores/PontosTempo.text = "5"
	$WrapperIndicadores/PontosProgresso.text = "0"
	$WrapperIndicadores/PontosConfianca.text="4"
	

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
	$CardContainer.add_child(current_card)
	
	# Configura a carta com os dados do JSON
	current_card.setup_card(cards_data[card_id])
	$CardContainer/Dilema.text = cards_data[card_id]["text"]
	
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
	$CardContainer.add_child(current_card)
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
	set_points($WrapperIndicadores/PontosMoral,direction,"moral")
	set_points($WrapperIndicadores/PontosRecursos,direction,"resources")
	set_points($WrapperIndicadores/PontosProgresso,direction,"progress")
	set_points($WrapperIndicadores/PontosTempo,direction,"time")
	set_points($WrapperIndicadores/PontosConfianca,direction,"trust")
		
	print("Carta descartada: ", direction)
	# Aqui você pode processar os efeitos da carta se quiser
	
	
	
		
	await show_feedback_card(card_data,direction)# Pede uma nova carta
	print(is_game_over())
	first_card = false
	
func is_game_over():
	if(first_card == false and ($WrapperIndicadores/PontosConfianca.text.to_int()<=0 or$WrapperIndicadores/PontosProgresso.text.to_int()<=0 or $WrapperIndicadores/PontosTempo.text.to_int()<=0 or $WrapperIndicadores/PontosRecursos.text.to_int()<=0 or $WrapperIndicadores/PontosMoral.text.to_int()<=0)):
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

	# Step 4: Add centered "GAME OVER" label
	var label := Label.new()
	label.text = "GAME OVER"
	

	# Center the label using anchors and alignment
	label.anchor_left = 0.5
	label.anchor_top = 0.5
	label.anchor_right = 0.5
	label.anchor_bottom = 0.5
	

	label.offset_left = 0
	label.offset_top = 0
	label.offset_right = 0
	label.offset_bottom = 0

	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	label.add_theme_font_size_override("font_size", 64)
	label.modulate = Color.WHITE

	black_overlay.add_child(label)

		
