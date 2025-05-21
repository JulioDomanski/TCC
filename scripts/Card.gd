extends Control

signal card_discarded(direction, card_data)

var dragging = false
var drag_offset = Vector2()
var initial_position = Vector2()
var initial_global_position = Vector2()
const SWIPE_THRESHOLD = 200

# Referências aos nós
onready var texture_rect = $TextureRect
onready var label_text = $Label
onready var label_left = $LeftChoiceLabel
onready var label_right = $RightChoiceLabel

var card_data = {}

func _ready():
	
	initial_position = rect_position
	initial_global_position = rect_global_position
	mouse_filter = Control.MOUSE_FILTER_STOP
	label_left.modulate.a = 0
	label_right.modulate.a = 0

func setup_card(data):
	card_data = data
	
	# Carrega a imagem da carta
	if card_data.has("image"):
		var image_texture = load(card_data["image"])
		if image_texture:
			texture_rect.texture = image_texture
	
	# Configura os textos
	label_text.text = card_data["text"]
	if card_data.has("left_choice"):
		label_left.text = card_data["left_choice"]
	if card_data.has("right_choice"):
		label_right.text = card_data["right_choice"]

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.pressed:
			# Começar a arrastar
			dragging = true
			drag_offset = rect_global_position - event.global_position
			# Pequena animação de "pegar" a carta
			var tween = get_tree().create_tween()
			tween.tween_property(self, "rect_scale", Vector2(1.05, 1.05), 0.1)
		else:
			# Soltar a carta
			if dragging:
				dragging = false
				# Retorna ao tamanho normal
				var tween = get_tree().create_tween()
				tween.tween_property(self, "rect_scale", Vector2(1, 1), 0.1)
				process_swipe()
	
	elif event is InputEventMouseMotion and dragging:
		# Movimento suave apenas no eixo X
		var new_pos = event.global_position + drag_offset
		rect_global_position = Vector2(new_pos.x, initial_global_position.y)
		update_choice_visibility()

func process_swipe():
	var delta_x = rect_global_position.x - initial_global_position.x
	
	if delta_x > SWIPE_THRESHOLD:
		discard_card("right")
	elif delta_x < -SWIPE_THRESHOLD:
		discard_card("left")
	else:
		return_to_center()

func discard_card(direction):
	var viewport_size = get_viewport_rect().size
	var target_x = viewport_size.x if direction == "right" else -viewport_size.x
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "rect_global_position:x", target_x, 0.3)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(self, "modulate:a", 0, 0.3)
	tween.connect("finished", self, "_on_discard_complete", [direction])

func _on_discard_complete(direction):
	emit_signal("card_discarded", direction, card_data)
	queue_free()
	
func update_choice_visibility():
	var delta_x = rect_global_position.x - initial_global_position.x
	var viewport_width = get_viewport_rect().size.x
	
	# Se arrastando para esquerda
	if delta_x < 0:
		var left_strength = clamp(abs(delta_x)/SWIPE_THRESHOLD, 0, 1)
		label_left.modulate.a = left_strength
		label_right.modulate.a = 0
	
	# Se arrastando para direita
	elif delta_x > 0:
		var right_strength = clamp(delta_x/SWIPE_THRESHOLD, 0, 1)
		label_right.modulate.a = right_strength
		label_left.modulate.a = 0
	
	# Se no centro
	else:
		label_left.modulate.a = 0
		label_right.modulate.a = 0


func return_to_center():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "rect_global_position", initial_global_position, 0.3)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(label_left, "modulate:a", 0, 0.2)
	tween.parallel().tween_property(label_right, "modulate:a", 0, 0.2)
