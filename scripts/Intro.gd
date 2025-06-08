extends Control

@onready var texture_rect: TextureRect
@onready var label: Label
@onready var  button: Button
@onready var vbox : VBoxContainer
@onready var personagem_texture : TextureRect
@onready var personagem_label : Label
@onready var personagem_nome : Label
@onready var center : CenterContainer

var mostrar_capitulo = false
var personagem_index = 0
var scene_counter := 1
var personagens = [
	{
		"nome": "Sir Cedric",
		"imagem": "res://assets/personagemIntro/Sir Cedric.png",
		"descricao": "Cavaleiro disciplinado, defensor da comunicação constante e do aprendizado iterativo."
	},
	{
		"nome": "Lady Elara",
		"imagem": "res://assets/personagemIntro/Lady Elara.png",
		"descricao": "Estrategista da corte, visionária e defensora da entrega contínua de valor."
	},
	{
		"nome": "Guilda dos Anoes",
		"imagem": "res://assets/personagemIntro/Anoes.png",
		"descricao": "Trabalhadores do reino, fortes, mas desorganizados sem liderança."
	},
	{
		"nome":"Rainha Stakeholdina",
		"imagem": "res://assets/personagemIntro/Rainha Stakeholdina.png",
		"descricao" : "Majestade firme e perspicaz, sempre vigilante às necessidades do reino e movida pelo desejo de ver resultados concretos."
	}
]

func _ready() : 
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

	var label_black_screen := Label.new()
	label_black_screen.text = "Reino de Entregária.\n Ano 1265 do Calendário dos Ciclos."
	label_black_screen.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_black_screen.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	# Customize appearance
	label_black_screen.add_theme_font_size_override("font_size", 30)
	label_black_screen.modulate = Color(0, 0, 0, 0)

	# Fade in effect
	var tween_label := create_tween()
	tween_label.tween_property(label_black_screen, "modulate", Color(1, 1, 1, 1), 1.0)

	center_container.add_child(label_black_screen)
	await get_tree().create_timer(3.0).timeout
	
		# Step 5: Fade out black overlay and label
	var fade_out := create_tween()
	fade_out.tween_property(black_overlay, "modulate", Color(0, 0, 0, 0), 1.0)
	fade_out.tween_property(label_black_screen, "modulate", Color(1, 1, 1, 0), 1.0)
	await fade_out.finished

	# Step 6: Remove label and overlay (optional)
	center_container.queue_free()  # removes both center_container and label
	black_overlay.queue_free()

	# Step 7: Create and fade in TextureRect
	# Step 7: Create and fade in TextureRect (REUSABLE)
	texture_rect = TextureRect.new()
	texture_rect.texture = preload("res://assets/backgroundIntro/PrimeiraFoto.png")
	texture_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH
	texture_rect.modulate = Color(1, 1, 1, 0)
	add_child(texture_rect)

	var fade_in := create_tween()
	fade_in.tween_property(texture_rect, "modulate", Color(1, 1, 1, 1), 1.5)
	
	vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(vbox)
	# Create label (REUSABLE)
	label = Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	label.add_theme_font_size_override("font_size", 30)
	label.modulate = Color.WHITE
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.add_child(label)

	# Typewriter effect
	await typewriter_text(label, "Reinava a ordem sob o Rei Ganttus, mestre das previsões e dos planos imutáveis.\nMas os ventos mudaram... e o Caos Escopial, avatar da imprevisibilidade, fez ruir aquilo que se acreditava eterno")

	# Create Button (REUSABLE)
	button = Button.new()
	button.text = "Continuar"
	button.custom_minimum_size = Vector2(180, 50)
	button.add_theme_font_size_override("font_size", 22)
	button.modulate = Color(1, 1, 1, 0)
	add_child(button)

	# Bottom-right anchors
	button.anchor_left = 1
	button.anchor_top = 1
	button.anchor_right = 1
	button.anchor_bottom = 1
	button.offset_right = -30
	button.offset_bottom = -30
	button.offset_left = -210
	button.offset_top = -80
	button.z_index = 3

	# Fade in button
	var tween_button := create_tween()
	tween_button.tween_property(button, "modulate", Color(1, 1, 1, 1), 1.0)

	button.pressed.connect(_on_continue_pressed)
	
	


	
	
func typewriter_text(label: Label, full_text: String, delay: float = 0.05) -> void:
	label.text = ""  # Start empty
	for i in full_text.length():
		label.text += full_text[i]
		await get_tree().create_timer(delay).timeout

func mostrar_personagem(index: int):
	
	if(mostrar_capitulo != true):
		var dados = personagens[index]
		personagem_texture.texture = load(dados["imagem"])
		personagem_label.text = dados["descricao"]
		personagem_nome.text = dados["nome"]

		# Fade in
		var fade_in = create_tween()
		
		fade_in.tween_property(personagem_texture, "modulate", Color(1, 1, 1, 1), 1.0)
		fade_in.tween_property(personagem_nome, "modulate", Color(1, 1, 1, 1), 1.0)
		fade_in.tween_property(personagem_label, "modulate", Color(1, 1, 1, 1), 1.0)
		await fade_in.finished
		var fade_in_button = create_tween()
		fade_in_button.tween_property(button, "modulate", Color(1, 1, 1, 1), 1.0)
		
		personagem_index+=1
	
		if personagem_index >= personagens.size():
			mostrar_capitulo = true
			return
	
	

func _on_continue_pressed():
	if(mostrar_capitulo != true):
		if(scene_counter == 1):
			# Fade out current image and label
			var fade_out := create_tween()
			fade_out.tween_property(texture_rect, "modulate", Color(1, 1, 1, 0), 1.0)
			fade_out.tween_property(label, "modulate", Color(1, 1, 1, 0), 1.0)
			fade_out.tween_property(button, "modulate", Color(1, 1, 1, 0), 0.5)
			await fade_out.finished

			# Swap texture and label text
			texture_rect.texture = preload("res://assets/backgroundIntro/SegundaFoto.png")
			label.text = ""
			label.modulate = Color(1, 1, 1, 1)

			# Fade in image again
			var fade_in := create_tween()
			fade_in.tween_property(texture_rect, "modulate", Color(1, 1, 1, 1), 1.0)
			await fade_in.finished

			# Type new text
			await typewriter_text(label, "Com o trono vago e o reino desolado, recai sobre ti, jovem herdeiro, a missão de reconstrução.
		Mas não com correntes... com ciclos. Não com decretos... com colaboração.
		Bem-vindo ao desafio da nova liderança.
		Agora, conheça os bravos heróis que caminharão ao teu lado nessa jornada.")

			# Fade in button again
			var fade_in_btn := create_tween()
			fade_in_btn.tween_property(button, "modulate", Color(1, 1, 1, 1), 1.0)
			

			# You can continue this flow by changing textures/text again in more button presses
			
		if(scene_counter == 2):
			var fade_out := create_tween()
			fade_out.tween_property(label, "modulate", Color(1, 1, 1, 0), 1.0)
			fade_out.tween_property(button, "modulate", Color(1, 1, 1, 0), 0.5)
			await fade_out.finished
			label.queue_free()
			vbox.queue_free()
			# CenterContainer to center everything
			var center := CenterContainer.new()
			center.set_anchors_preset(Control.PRESET_FULL_RECT)
			center.mouse_filter = Control.MOUSE_FILTER_IGNORE
			add_child(center)

			# VBoxContainer to stack image + label vertically
			var character_box := VBoxContainer.new()
			character_box.alignment = BoxContainer.ALIGNMENT_CENTER
			character_box.set_anchors_preset(Control.PRESET_CENTER)
			center.add_child(character_box)
			
			personagem_nome = Label.new()
			personagem_nome.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			personagem_nome.vertical_alignment = VERTICAL_ALIGNMENT_TOP
			personagem_nome.add_theme_font_size_override("font_size", 35)
			personagem_nome.modulate = Color(1, 1, 1, 0)
			character_box.add_child(personagem_nome)
			# TextureRect for character image
			personagem_texture = TextureRect.new()
			personagem_texture.expand_mode = TextureRect.EXPAND_FIT_WIDTH
			personagem_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			personagem_texture.custom_minimum_size = Vector2(400, 400)
			personagem_texture.modulate = Color(1, 1, 1, 0)
			personagem_texture.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			character_box.add_child(personagem_texture)
			

			# Label for description
			personagem_label = Label.new()
			personagem_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			personagem_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
			personagem_label.autowrap_mode = TextServer.AUTOWRAP_WORD
			personagem_label.add_theme_font_size_override("font_size", 26)
			personagem_label.modulate = Color(1, 1, 1, 0)
			personagem_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			character_box.add_child(personagem_label)


			await mostrar_personagem(personagem_index)
			
			var fade_in_btn := create_tween()
			fade_in_btn.tween_property(button, "modulate", Color(1, 1, 1, 1), 1.0)
			
			
			
			
		if(scene_counter >= 3):
			
			
			var fade_out := create_tween()
			fade_out.tween_property(personagem_texture, "modulate", Color(1, 1, 1, 0), 1.0)
			fade_out.tween_property(personagem_nome, "modulate", Color(1, 1, 1, 0), 0.5)
			fade_out.tween_property(personagem_label, "modulate", Color(1, 1, 1, 0), 0.5)
			fade_out.tween_property(button, "modulate", Color(1, 1, 1, 0), 0.5)
			await fade_out.finished
			mostrar_personagem(personagem_index)
		scene_counter += 1
	else:
		var fade_out_personagem = create_tween()
		fade_out_personagem.tween_property(button, "modulate", Color(1, 1, 1, 0), 0.5)
		fade_out_personagem.tween_property(personagem_texture, "modulate", Color(1, 1, 1, 0), 1.0)
		fade_out_personagem.tween_property(personagem_nome, "modulate", Color(1, 1, 1, 0), 0.5)
		fade_out_personagem.tween_property(personagem_label, "modulate", Color(1, 1, 1, 0), 0.5)
		await fade_out_personagem.finished
		personagem_texture.queue_free()
		personagem_label.queue_free()
		
		var fade_in_capitulo = create_tween()
		personagem_nome.text = "Capitulo 1:"
		fade_in_capitulo.tween_property(personagem_nome, "modulate", Color(1, 1, 1, 1), 1.0)
		

	
	
