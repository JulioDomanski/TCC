extends Control

signal transition_finished

var texture_rect: TextureRect
var label: Label
var button: Button

func _ready():
	# --- Background ---
	texture_rect = TextureRect.new()
	texture_rect.texture = preload("res://assets/backgroundIntro/SextaFoto.png")
	texture_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH
	add_child(texture_rect)

	# --- Central narrative text ---
	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_child(vbox)

	label = Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	label.add_theme_font_size_override("font_size", 28)
	label.modulate = Color(1, 1, 1, 1)
	label.add_theme_constant_override("margin_left", 20)
	label.add_theme_constant_override("margin_right", 20)
	vbox.add_child(label)

	# --- Typewriter text ---
	await typewriter_text(label,
		"O ritmo da reconstrução está estabelecido, mas as sombras se agitam..." +
		"\nO Caos Escopial espreita, trazendo mudanças inesperadas e testando a resiliência do reino." +
		"\nÉ hora de provar que a agilidade não está apenas nos planos, mas na capacidade de se adaptar."
	)

	# --- Continue button ---
	button = Button.new()
	button.text = "Avançar para o Capítulo 5"
	button.custom_minimum_size = Vector2(220, 60)
	button.add_theme_font_size_override("font_size", 22)
	button.modulate = Color(1, 1, 1, 1)
	button.z_index = 12
	add_child(button)

	# Ancorar botão no canto inferior direito
	button.anchor_left = 1
	button.anchor_top = 1
	button.anchor_right = 1
	button.anchor_bottom = 1
	button.offset_right = -30
	button.offset_bottom = -30
	button.offset_left = -320
	button.offset_top = -80

	button.pressed.connect(_on_continue_pressed)


# --- Typewriter effect ---
func typewriter_text(label: Label, full_text: String, delay: float = 0.05) -> void:
	label.text = ""
	for i in range(full_text.length()):
		label.text += full_text[i]
		await get_tree().create_timer(delay).timeout


# --- Continue button pressed ---
func _on_continue_pressed():
	
	# Fade out narrative + button
	var fade_out := create_tween()
	fade_out.tween_property(label, "modulate:a", 0.0, 0.5)
	fade_out.tween_property(button, "modulate:a", 0.0, 0.5)
	await fade_out.finished

	# --- Show Chapter 5 Title ---
	var center_container = CenterContainer.new()
	center_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center_container)

	var vbox_capitulo = VBoxContainer.new()
	vbox_capitulo.alignment = BoxContainer.ALIGNMENT_CENTER
	center_container.add_child(vbox_capitulo)

	var capitulo_label = Label.new()
	capitulo_label.text = "Capítulo 5: As Sombras do Caos Escopial"
	capitulo_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	capitulo_label.add_theme_font_size_override("font_size", 32)
	capitulo_label.modulate.a = 0.0
	vbox_capitulo.add_child(capitulo_label)

	var conceitos_label = Label.new()
	conceitos_label.text = "Conceitos: Adaptação ao Caos, Resiliência, Gestão de Crises"
	conceitos_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	conceitos_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	conceitos_label.add_theme_font_size_override("font_size", 24)
	conceitos_label.modulate.a = 0.0
	vbox_capitulo.add_child(conceitos_label)

	# --- Fade in chapter labels ---
	var fade_in_capitulo = create_tween()
	fade_in_capitulo.tween_property(capitulo_label, "modulate:a", 1.0, 1.0)
	fade_in_capitulo.tween_property(conceitos_label, "modulate:a", 1.0, 1.0)
	await fade_in_capitulo.finished

	await get_tree().create_timer(4.0).timeout

	# --- Fade out chapter labels ---
	var fade_out_capitulo = create_tween()
	fade_out_capitulo.tween_property(capitulo_label, "modulate:a", 0.0, 1.0)
	fade_out_capitulo.tween_property(conceitos_label, "modulate:a", 0.0, 1.0)
	await fade_out_capitulo.finished


	emit_signal("transition_finished")
	
	
	# Pequeno delay para garantir processamento
	await get_tree().create_timer(0.1).timeout
	queue_free()
	
