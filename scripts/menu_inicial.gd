extends Control

@onready var btn_new_game = $TextureRect/CenterContainer/VBoxContainer/BtnNewGame
@onready var btn_continue =$TextureRect/CenterContainer/VBoxContainer/BtnContinue
@onready var btn_progress = $TextureRect/CenterContainer/VBoxContainer/BtnProgress
@onready var btn_sair = $TextureRect/CenterContainer/VBoxContainer/BtnSair
@onready var texture_rect = $TextureRect
@onready var title = $TextureRect/CenterContainer2/TitleGame
@onready var menu = $TextureRect/CenterContainer/VBoxContainer
@onready var sfx_intro = $SfxIntro 

func _ready():
	# Inicialmente esconde tudo
	texture_rect.modulate.a = 0
	title.modulate.a = 0
	title.scale = Vector2(0.8, 0.8)
	menu.modulate.a = 0

	# Conecta sinais
	btn_new_game.connect("pressed", Callable(self, "_on_new_game_pressed"))
	btn_continue.connect("pressed", Callable(self, "_on_continue_pressed"))
	btn_progress.connect("pressed", Callable(self, "_on_progress_pressed"))
	btn_sair.connect("pressed", Callable(self, "_on_exit_pressed"))

	
	var tween = get_tree().create_tween()
	
	
	tween.tween_property(texture_rect, "modulate:a", 1, 3.0)
	
	
	tween.tween_interval(0.3) 
	tween.tween_callback(Callable(self, "_play_intro_sfx"))
	tween.tween_property(title, "modulate:a", 1, 1.5)
	tween.parallel().tween_property(title, "scale", Vector2(1, 1), 0.8).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	
	tween.tween_interval(0.5)
	tween.tween_property(menu, "modulate:a", 1, 1.5)
	
func _play_intro_sfx():
	if sfx_intro:
		sfx_intro.play()


func _on_new_game_pressed():
	# Reinicia o jogo do zero
	print("Novo Jogo iniciado!")
	get_tree().change_scene_to_file("res://scenes/Intro.tscn")

func _on_continue_pressed():
	# Aqui você carrega o save do jogador
	if FileAccess.file_exists("user://savegame.save"):
		print("Carregar jogo salvo...")
		get_tree().change_scene_to_file("res://scenes/Game.tscn")
		# no _ready() da Game, você lê o save
	else:
		print("Nenhum jogo salvo encontrado")

func _on_progress_pressed():
	# Pode abrir uma tela de progresso, conquistas, capítulos desbloqueados etc
	print("Abrir tela de progresso")
	get_tree().change_scene_to_file("res://scenes/Progress.tscn")
	
func _on_exit_pressed():
	get_tree().quit()
