extends Control

@onready var tween := create_tween()

func _ready():
	scale.y = 0.0
	hide()

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
	print("Abrir opções")

func _on_button_sair_pressed():
	get_tree().paused = false
	get_tree().quit()
