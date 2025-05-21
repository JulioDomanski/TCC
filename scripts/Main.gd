extends Control

const CardScene = preload("res://scenes/Card.tscn")

var deck = [] # Array com os IDs das cartas
var current_card = null
var cards_data = {} # Dicionário para armazenar todas as cartas

func _ready():
	load_cards_data()
	initialize_deck()
	spawn_new_card()

func load_cards_data():
	var file = File.new()
	if not file.file_exists("res://data/cards.json"):
		push_error("Arquivo cards.json não encontrado!")
		return
	
	file.open("res://data/cards.json", File.READ)
	var json_data = file.get_as_text()
	file.close()
	
	var json_result = JSON.parse(json_data)
	if json_result.error != OK:
		push_error("Erro ao analisar JSON: ")
		return
	
	# Converte o array de cartas para um dicionário por ID
	for card in json_result.result:
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
	var card_id = deck.pop_front()
	print("Carta atual - ID: ", card_id)
	
	# Cria a nova carta
	current_card = CardScene.instance()
	$CardContainer.add_child(current_card)
	
	# Configura a carta com os dados do JSON
	current_card.setup_card(cards_data[card_id])
	
	# Conecta o sinal para saber quando a carta foi descartada
	current_card.connect("card_discarded", self, "_on_card_discarded")
	

func _on_card_discarded(direction, card_data):
	print("Carta descartada: ", direction)
	# Aqui você pode processar os efeitos da carta se quiser
	spawn_new_card() # Pede uma nova carta
