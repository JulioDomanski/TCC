extends Control

@onready var label: Label = $Label 
@onready var button: Button = $Button
@onready var vbox: VBoxContainer = $VBoxContainer
@onready var end_music: AudioStreamPlayer = $EndMusic

var texture_rect: TextureRect

var scene_counter := 1
var final_scene_texts = [
	"Os monstros do caos escopial foram derrotados e seus sussurros de imprevisibilidade silenciados para sempre.\n Graças a você, jovem Príncipe, que com sabedoria e coragem, aplicou ciclos curtos e iterativos para restaurar a glória de Entregária.",
	"O reino, antes desolado, agora floresce sob sua nova liderança. Cada Sprint trouxe uma camada de esperança, cada Daily Scrum reforçou a colaboração.\n A torre mais alta do castelo se reergueu, um farol de transparência e adaptação para todas as terras.",
	"Com o Backlog cumprido, o reino se enche de projetos de prosperidade. O povo, unido e resiliente, ergue suas vozes em celebração.\n O reinado da ordem e da eficiência foi estabelecido, um legado forjado na agilidade e na coragem.",
	"Parabéns, Jovem Princípe!"
]

func _ready() :
	var black_overlay := ColorRect.new()
	black_overlay.color = Color(0, 0, 0, 1)
	black_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	black_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(black_overlay)

	var tween_fade_in_overlay := create_tween()
	tween_fade_in_overlay.tween_property(black_overlay, "color", Color(0, 0, 0, 0), 1.4)
	await tween_fade_in_overlay.finished
	black_overlay.queue_free()

	end_music.volume_db = -10
	end_music.play()
	print("DEBUG: Música tocando.")

	texture_rect = TextureRect.new()
	texture_rect.texture = preload("res://assets/backgroundIntro/OitavaFoto.png")
	texture_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH
	texture_rect.modulate = Color(1, 1, 1, 0)
	texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(texture_rect)
	texture_rect.z_index = -1

	var fade_in_image := create_tween()
	fade_in_image.tween_property(texture_rect, "modulate", Color(1, 1, 1, 1), 1.5)
	
	# Verificação do VBox (removida se não estiver usando, mas mantida por enquanto)
	if vbox:
		print("DEBUG: VBoxContainer encontrado. Definindo mouse_filter.")
		vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	else:
		print("ERRO: VBoxContainer NÃO ENCONTRADO! Verifique o nome/caminho.")

	# --- CORREÇÃO E AJUSTE DO LABEL ---
	if label:
		print("DEBUG: Label encontrada. Definindo mouse_filter.")
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		# --- SOLUÇÃO PARA LARGURA ---
		# Define as âncoras para 10% da esquerda e 90% da direita (80% de largura total)
		label.anchor_left = 0.1
		label.anchor_right = 0.9
		# Reseta as margens para que as âncoras funcionem
		label.offset_left = 0
		label.offset_right = 0
		# --- FIM DA SOLUÇÃO ---

		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		label.modulate = Color(1, 1, 1, 1)

		var label_theme = Theme.new()
		var stylebox_flat = StyleBoxFlat.new()
		stylebox_flat.bg_color = Color(0, 0, 0, 0.28)
		stylebox_flat.set_content_margin(SIDE_LEFT, 10)
		stylebox_flat.set_content_margin(SIDE_RIGHT, 10)
		stylebox_flat.set_content_margin(SIDE_TOP, 5)
		stylebox_flat.set_content_margin(SIDE_BOTTOM, 5)
		
		label_theme.set_stylebox("normal", "Label", stylebox_flat)
		label.add_theme_font_size_override("font_size", 30)
		label.theme = label_theme

		await typewriter_text(label, final_scene_texts[0])
	else:
		print("ERRO: Label DENTRO do VBoxContainer NÃO ENCONTRADA! Verifique o nome/caminho.")
		return
	# --- FIM DA CORREÇÃO (CÓDIGO DUPLICADO REMOVIDO) ---

	# Configuração do Botão
	button.text = "Continuar"
	button.custom_minimum_size = Vector2(180, 50)
	button.add_theme_font_size_override("font_size", 22)
	button.modulate = Color(1, 1, 1, 0)

	button.anchor_left = 1
	button.anchor_top = 1
	button.anchor_right = 1
	button.anchor_bottom = 1
	button.offset_right = -30
	button.offset_bottom = -30
	button.offset_left = -210
	button.offset_top = -80
	button.z_index = 3

	button.mouse_filter = Control.MOUSE_FILTER_STOP

	var tween_button := create_tween()
	tween_button.tween_property(button, "modulate", Color(1, 1, 1, 1), 1.0)
	await tween_button.finished

	if not button.is_connected("pressed", Callable(self, "_on_continue_pressed")):
		button.pressed.connect(_on_continue_pressed)
		print("DEBUG: Botão 'Continue' conectado.")
	else:
		print("DEBUG: Botão 'Continue' já estava conectado.")

func typewriter_text(label_node: Label, full_text: String, delay: float = 0.05) -> void:
	label_node.text = ""
	for i in full_text.length():
		label_node.text += full_text[i]
		await get_tree().create_timer(delay).timeout

func _on_continue_pressed():
	scene_counter += 1

	var fade_out := create_tween()
	fade_out.tween_property(label, "modulate", Color(1, 1, 1, 0), 0.7)
	fade_out.tween_property(button, "modulate", Color(1, 1, 1, 0), 0.5)
	await fade_out.finished

	if scene_counter == 2:
		var fade_image_out := create_tween()
		fade_image_out.tween_property(texture_rect, "modulate", Color(1, 1, 1, 0), 1.0)
		await fade_image_out.finished

		texture_rect.texture = preload("res://assets/backgroundIntro/NonaFoto.png")
		var fade_image_in := create_tween()
		fade_image_in.tween_property(texture_rect, "modulate", Color(1, 1, 1, 1), 1.0)
		await fade_image_in.finished

		label.text = ""
		label.modulate = Color(1, 1, 1, 1)
		await typewriter_text(label, final_scene_texts[1])

		var fade_in_btn := create_tween()
		fade_in_btn.tween_property(button, "modulate", Color(1, 1, 1, 1), 1.0)

	elif scene_counter == 3:
		label.text = ""
		label.modulate = Color(1, 1, 1, 1)
		await typewriter_text(label, final_scene_texts[2])
		var fade_in_btn := create_tween()
		fade_in_btn.tween_property(button, "modulate", Color(1, 1, 1, 1), 1.0)
		
	elif scene_counter == 4:
		label.text = ""
		label.modulate = Color(1, 1, 1, 1)
		await typewriter_text(label, final_scene_texts[3])
		button.text = "Voltar ao Menu"
		var fade_in_btn := create_tween()
		fade_in_btn.tween_property(button, "modulate", Color(1, 1, 1, 1), 1.0)

	else:
		var fade_rect = ColorRect.new()
		fade_rect.color = Color(0, 0, 0, 0)
		fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
		fade_rect.z_index = 100
		add_child(fade_rect)

		var tween_visual = create_tween()
		tween_visual.tween_property(fade_rect, "color", Color(0, 0, 0, 1), 2.0)

		if end_music:
			var tween_audio = create_tween()
			tween_audio.tween_property(end_music, "volume_db", -80, 2.0)
		
		await tween_visual.finished
		
		if end_music:
			end_music.stop()

		get_tree().change_scene_to_file("res://scenes/MenuInicial.tscn")
