extends PopupPanel

@export var texto_summary: String = "Sumário padrão"

@onready var margin_container = $MarginContainer
@onready var vbox_container = $MarginContainer/VBoxContainer
@onready var label_summary = $MarginContainer/VBoxContainer/RichTextLabel
@onready var button_continue = $MarginContainer/VBoxContainer/Button

func _ready():
	var fonte_pixel = load("res://assets/font/PixeloidSans-mLxMm.ttf")

	self.min_size = Vector2(500, 450) # Um tamanho bom para começar
	margin_container.add_theme_constant_override("margin_left", 20)
	margin_container.add_theme_constant_override("margin_right", 20)
	margin_container.add_theme_constant_override("margin_top", 20)
	margin_container.add_theme_constant_override("margin_bottom", 20)
	vbox_container.add_theme_constant_override("separation", 15)

	var estilo_painel = StyleBoxFlat.new()
	estilo_painel.bg_color = Color("#3B3029")
	estilo_painel.border_width_left = 2
	estilo_painel.border_width_top = 2
	estilo_painel.border_width_right = 2
	estilo_painel.border_width_bottom = 2
	estilo_painel.border_color = Color("#5C4A3E")
	estilo_painel.corner_radius_top_left = 10
	estilo_painel.corner_radius_top_right = 10
	estilo_painel.corner_radius_bottom_left = 10
	estilo_painel.corner_radius_bottom_right = 10
	estilo_painel.shadow_size = 5
	estilo_painel.shadow_color = Color(0, 0, 0, 0.25)
	add_theme_stylebox_override("panel", estilo_painel)


	label_summary.bbcode_enabled = true 
	label_summary.add_theme_font_override("normal_font", fonte_pixel)
	label_summary.add_theme_font_size_override("normal_font_size", 18)
	label_summary.add_theme_color_override("default_color", Color.WHITE)
	label_summary.add_theme_constant_override("line_separation", 8)
	
	button_continue.add_theme_font_override("font", fonte_pixel)
	button_continue.add_theme_font_size_override("font_size", 16)
	
	var estilo_botao_normal = StyleBoxFlat.new()
	estilo_botao_normal.bg_color = Color("#5C4A3E") # Marrom mais claro
	estilo_botao_normal.corner_radius_top_left = 5
	estilo_botao_normal.corner_radius_top_right = 5
	estilo_botao_normal.corner_radius_bottom_left = 5
	estilo_botao_normal.corner_radius_bottom_right = 5
	button_continue.add_theme_stylebox_override("normal", estilo_botao_normal)

	var estilo_botao_hover = StyleBoxFlat.new()
	estilo_botao_hover.bg_color = Color("#7D6B5D")
	estilo_botao_hover.corner_radius_top_left = 5
	estilo_botao_hover.corner_radius_top_right = 5
	estilo_botao_hover.corner_radius_bottom_left = 5
	estilo_botao_hover.corner_radius_bottom_right = 5
	button_continue.add_theme_stylebox_override("hover", estilo_botao_hover)
	
	var estilo_botao_pressed = StyleBoxFlat.new()
	estilo_botao_pressed.bg_color = Color("#4A3C31")
	estilo_botao_pressed.corner_radius_top_left = 5
	estilo_botao_pressed.corner_radius_top_right = 5
	estilo_botao_pressed.corner_radius_bottom_left = 5
	estilo_botao_pressed.corner_radius_bottom_right = 5
	button_continue.add_theme_stylebox_override("pressed", estilo_botao_pressed)

	button_continue.text = "Continuar"
	label_summary.text = texto_summary
	
	# Conecta o sinal do botão
	button_continue.pressed.connect(_on_continue_pressed)

func _on_continue_pressed():
	hide()
