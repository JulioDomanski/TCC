extends Control

@onready var tween := create_tween()
@onready var main_menu = $PanelContainer/VBoxContainer
@onready var options_page = $PanelContainer/OptionsPage
@onready var music_slider = $PanelContainer/OptionsPage/ContainerMusica/music_slider
@onready var sfx_slider = $PanelContainer/OptionsPage/ContainerSfx/sfx_slider

func _ready():
	scale.y = 0.0
	hide()
	options_page.hide()
	

	# Ajustar sliders para valores atuais
	music_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))) * 100
	sfx_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))) * 100

	music_slider.connect("value_changed", Callable(self, "_on_music_slider_changed"))
	sfx_slider.connect("value_changed", Callable(self, "_on_sfx_slider_changed"))

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().paused = not get_tree().paused
		if get_tree().paused:
			show()
			abrir_menu()
		else:
			fechar_menu()

func abrir_menu():
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "scale:y", 1.0, 0.3) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func fechar_menu():
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "scale:y", 0.0, 0.3) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_callback(Callable(self, "hide"))

func _on_button_resumir_pressed():
	get_tree().paused = false
	fechar_menu()

func _on_button_opcoes_pressed():
	main_menu.hide()
	options_page.show()

func _on_button_sair_pressed():
	get_tree().paused = false
	get_tree().quit()

func _on_button_voltar_pressed():
	options_page.hide()
	main_menu.show()

# === Volume ===
func _on_music_slider_changed(value):
	var bus_idx = AudioServer.get_bus_index("Master")
	var db_value = linear_to_db(value / 100.0)
	AudioServer.set_bus_volume_db(bus_idx, db_value)

func _on_sfx_slider_changed(value):
	var bus_idx = AudioServer.get_bus_index("SFX")
	var db_value = linear_to_db(value / 100.0)
	AudioServer.set_bus_volume_db(bus_idx, db_value)
