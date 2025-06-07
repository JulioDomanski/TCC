extends Control

var texture_rect: TextureRect
var label: Label
var button: Button
var vbox : VBoxContainer


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

	var label := Label.new()
	label.text = "Reino de Entregária.\n Ano 1265 do Calendário dos Ciclos."
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	# Customize appearance
	label.add_theme_font_size_override("font_size", 30)
	label.modulate = Color(0, 0, 0, 0)

	# Fade in effect
	var tween_label := create_tween()
	tween_label.tween_property(label, "modulate", Color(1, 1, 1, 1), 1.0)

	center_container.add_child(label)
	await get_tree().create_timer(3.0).timeout
	
		# Step 5: Fade out black overlay and label
	var fade_out := create_tween()
	fade_out.tween_property(black_overlay, "modulate", Color(0, 0, 0, 0), 1.0)
	fade_out.tween_property(label, "modulate", Color(1, 1, 1, 0), 1.0)
	await fade_out.finished

	# Step 6: Remove label and overlay (optional)
	center_container.queue_free()  # removes both center_container and label
	black_overlay.queue_free()

	# Step 7: Create and fade in TextureRect
	texture_rect = TextureRect.new()
	texture_rect.texture = preload("res://assets/backgroundIntro/PrimeiraFoto.png")  # Replace with your image path
	texture_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH
	texture_rect.modulate = Color(1, 1, 1, 0)  # Start invisible

	add_child(texture_rect)

	# Fade it in
	var texture_fade := create_tween()
	texture_fade.tween_property(texture_rect, "modulate", Color(1, 1, 1, 1), 1.5)
	
	vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(vbox)

	label = Label.new()
	

	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	label.add_theme_font_size_override("font_size", 30)
	label.modulate = Color.WHITE

	vbox.add_child(label)

	center_container.add_child(label)
	await typewriter_text(label ,"Reinava a ordem sob o Rei Ganttus, mestre das previsões e dos planos imutáveis.
Mas os ventos mudaram... e o Caos Escopial, avatar da imprevisibilidade, fez ruir aquilo que se acreditava eterno")
	
	
	# === Button in Bottom-Right ===
	button = Button.new()
	button.text = "Continuar"
	button.custom_minimum_size = Vector2(180, 50)
	button.add_theme_font_size_override("font_size", 22)
	button.modulate = Color(1, 1, 1, 0)  # Start fully transparent
	add_child(button)

	# === Anchor to Bottom-Right ===
	button.anchor_left = 1
	button.anchor_top = 1
	button.anchor_right = 1
	button.anchor_bottom = 1

	button.offset_right = -30
	button.offset_bottom = -30
	button.offset_left = -210  # 180 width + 30 margin
	button.offset_top = -80    # 50 height + 30 margin

	# === Fade-in Tween (modulate.a)
	var tween_button := create_tween()
	tween_button.tween_property(button, "modulate", Color(1, 1, 1, 1), 1.0)


	# Connect signal
	button.pressed.connect(_on_continue_pressed)
	
func typewriter_text(label: Label, full_text: String, delay: float = 0.05) -> void:
	label.text = ""  # Start empty
	for i in full_text.length():
		label.text += full_text[i]
		await get_tree().create_timer(delay).timeout

func _on_continue_pressed():
	print("Button pressed! Moving to next scene...")
	# Example: get_tree().change_scene_to_file("res://next_scene.tscn")

		

	
