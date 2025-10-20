extends Control

signal card_discarded(direction, card_data)

var dragging = false
var drag_offset = Vector2()
var initial_position = Vector2()
var initial_global_position = Vector2()
const SWIPE_THRESHOLD = 200
var is_feedback_card = false
@onready var texture_rect = $TextureRect
@onready var label_feedback = $TextureRect/FeedbackBackground/LabelFeedback
@onready var label_left = $TextureRect/LeftChoiceLabel
@onready var label_right = $TextureRect/RightChoiceLabel
@onready var feedback_background = $TextureRect/FeedbackBackground
@onready var swipe_sound = $SwipeSound
@onready var viewport = get_viewport_rect()
@onready var frame = $TextureRect/Frame
var card_data = {}

func _notification(what: int) -> void:
	if viewport != get_viewport_rect():
		viewport = get_viewport_rect()
		initial_position = position
		initial_global_position = global_position

func _ready():
	initial_position = position
	initial_global_position = global_position
	mouse_filter = Control.MOUSE_FILTER_STOP
	label_left.modulate.a = 0
	label_right.modulate.a = 0
	frame.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	frame.set_anchors_preset(Control.PRESET_FULL_RECT)
	frame.anchor_left = 0
	frame.anchor_top = 0
	frame.anchor_right = 1.41
	frame.anchor_bottom = 2.3
	frame.offset_left = 0
	frame.offset_top = 0
	frame.offset_right = 0
	frame.offset_bottom = 0
	frame.z_index = 10
	frame.scale = Vector2(0.86, 0.59) 

func check_card(card_data) -> String:
	if card_data["image"] == "Sir Cedric":
		return "res://assets/Cards/SirCedric.png"
	if card_data["image"] == "Lady Elara":
		return "res://assets/Cards/LadyElara.png"
	if card_data["image"] == "Anoes":
		return "res://assets/Cards/Anoes.png"
	if card_data["image"] == "Rainha Stakeholdina":
		return "res://assets/Cards/RainhaStake.png"
	if card_data["image"] == "Caos Escopial":
		return "res://assets/Cards/Caos Escopial.PNG"
	return ""

func setup_card(data, is_feedback = false, direction = "right"):
	card_data = data
	is_feedback_card = is_feedback
	visible = false
	await get_tree().process_frame
	initial_position = position
	initial_global_position = global_position

	if card_data.has("image"):
		var image_texture = load(check_card(card_data))
		if image_texture:
			texture_rect.texture = image_texture

	if is_feedback:
		label_feedback.text = "Feedback:\n" + card_data["feedback"][direction]
		label_feedback.visible = true

		if card_data["correct_answer"] == direction:
			label_feedback.add_theme_color_override("font_color", Color.GREEN)
		else:
			label_feedback.add_theme_color_override("font_color", Color.RED)

		feedback_background.visible = true
		feedback_background.modulate.a = 0
		feedback_background.scale = Vector2(0.8, 0.8)
		feedback_background.color = Color(0.1, 0.1, 0.1, 0.85)
		var tween = get_tree().create_tween()
		tween.tween_property(label_feedback, "modulate:a", 1, 0.4)
		tween.parallel().tween_property(label_feedback, "scale", Vector2(1, 1), 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(feedback_background, "modulate:a", 1, 0.4)
		tween.parallel().tween_property(feedback_background, "scale", Vector2(1, 1), 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	else:
		label_left.text = data.get("left_choice", "")
		label_right.text = data.get("right_choice", "")
		label_feedback.visible = false
		feedback_background.visible = false
		label_left.visible = true
		label_right.visible = true

	# --- ANIMAÇÃO DE ENTRADA ---
	global_position = Vector2(initial_global_position.x, get_viewport_rect().size.y + size.y)
	modulate.a = 0
	scale = Vector2(0.9, 0.9)
	visible = true

	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position", initial_global_position, 0.5)
	tween.parallel().tween_property(self, "modulate:a", 1, 0.3)
	tween.parallel().tween_property(self, "scale", Vector2(1, 1), 0.4)

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			dragging = true
			drag_offset = get_global_position() - event.global_position

			var tween = get_tree().create_tween()
			tween.tween_property(self, "scale", Vector2(1.05, 1.05), 0.1)
		else:
			if dragging:
				dragging = false
				var tween = get_tree().create_tween()
				tween.tween_property(self, "scale", Vector2(1, 1), 0.1)
				process_swipe()

	elif event is InputEventMouseMotion and dragging:
		var new_pos = event.global_position + drag_offset
		global_position = Vector2(new_pos.x, initial_global_position.y)
		update_choice_visibility()
		
		if not is_feedback_card:
			# Escurece proporcional ao quanto está arrastando
			var delta_x = abs(global_position.x - initial_global_position.x)
			var strength = clamp(delta_x / SWIPE_THRESHOLD, 0, 1)
			var darkness = clamp(strength * 3, 0, 3) 
			feedback_background.visible = true
			feedback_background.modulate = Color(0, 0, 0, darkness)
			
func process_swipe():
	var delta_x = global_position.x - initial_global_position.x

	if delta_x > SWIPE_THRESHOLD:
		discard_card("right")
		swipe_sound.play()
	elif delta_x < -SWIPE_THRESHOLD:
		discard_card("left")
		swipe_sound.play()
	else:
		return_to_center()

func discard_card(direction):
	var viewport_size = get_viewport_rect().size
	var target_x = viewport_size.x if direction == "right" else -viewport_size.x
	var target_y = global_position.y + 300  

	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(self, "global_position", Vector2(target_x, target_y), 0.3)
	tween.parallel().tween_property(self, "modulate:a", 0, 0.3)
	tween.connect("finished", Callable(self, "_on_discard_complete").bind(direction))

func _on_discard_complete(direction):
	emit_signal("card_discarded", direction, card_data)
	queue_free()

func update_choice_visibility():
	var delta_x = global_position.x - initial_global_position.x
	var viewport_width = get_viewport_rect().size.x

	if delta_x < 0:
		var left_strength = clamp(abs(delta_x) / SWIPE_THRESHOLD, 0, 1)
		label_left.modulate.a = left_strength
		label_right.modulate.a = 0
	elif delta_x > 0:
		var right_strength = clamp(delta_x / SWIPE_THRESHOLD, 0, 1)
		label_right.modulate.a = right_strength
		label_left.modulate.a = 0
	else:
		label_left.modulate.a = 0
		label_right.modulate.a = 0

func return_to_center():
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position", initial_global_position, 0.3)
	tween.parallel().tween_property(label_left, "modulate:a", 0, 0.2)
	tween.parallel().tween_property(label_right, "modulate:a", 0, 0.2)
	if not is_feedback_card:
		tween.parallel().tween_property(feedback_background, "modulate", Color(1,1,1,0), 0.2)
