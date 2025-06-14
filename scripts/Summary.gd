extends PopupPanel

# Propriedade para receber o texto de fora
@export var texto_summary: String = "Sumário padrão"

# Referências para os nós da cena
@onready var margin_container = $MarginContainer
@onready var vbox_container = $MarginContainer/VBoxContainer
@onready var label_summary = $MarginContainer/VBoxContainer/RichTextLabel
@onready var button_continue = $MarginContainer/VBoxContainer/Button

func _ready():
	# --- INÍCIO DA ESTILIZAÇÃO COMPLETA VIA CÓDIGO ---

	# 1. CARREGANDO RECURSOS (A FONTE)
	# Troque "sua_fonte_pixel.ttf" pelo nome do seu arquivo de fonte!
	var fonte_pixel = load("res://assets/font/PixeloidSans-mLxMm.ttf")

	# 2. CONFIGURANDO O LAYOUT (TAMANHO, MARGENS E ESPAÇAMENTO)
	self.min_size = Vector2(500, 450) # Um tamanho bom para começar
	margin_container.add_theme_constant_override("margin_left", 20)
	margin_container.add_theme_constant_override("margin_right", 20)
	margin_container.add_theme_constant_override("margin_top", 20)
	margin_container.add_theme_constant_override("margin_bottom", 20)
	vbox_container.add_theme_constant_override("separation", 15)

	# 3. ESTILIZANDO O PAINEL PRINCIPAL (FUNDO)
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

	# 4. ESTILIZANDO O TEXTO (LABEL)
	label_summary.bbcode_enabled = true # Habilita tags como [center]
	label_summary.add_theme_font_override("normal_font", fonte_pixel)
	label_summary.add_theme_font_size_override("normal_font_size", 18)
	label_summary.add_theme_color_override("default_color", Color.WHITE) # Cor padrão do texto
	label_summary.add_theme_constant_override("line_separation", 8)

	# 5. ESTILIZANDO O BOTÃO (TODOS OS ESTADOS)
	button_continue.add_theme_font_override("font", fonte_pixel)
	button_continue.add_theme_font_size_override("font_size", 16)
	
	# Estilo do botão Normal
	var estilo_botao_normal = StyleBoxFlat.new()
	estilo_botao_normal.bg_color = Color("#5C4A3E") # Marrom mais claro
	estilo_botao_normal.corner_radius_top_left = 5
	estilo_botao_normal.corner_radius_top_right = 5
	estilo_botao_normal.corner_radius_bottom_left = 5
	estilo_botao_normal.corner_radius_bottom_right = 5
	button_continue.add_theme_stylebox_override("normal", estilo_botao_normal)

	# Estilo do botão com mouse em cima (Hover)
	var estilo_botao_hover = StyleBoxFlat.new()
	estilo_botao_hover.bg_color = Color("#7D6B5D") # Um pouco mais claro
	estilo_botao_hover.corner_radius_top_left = 5
	estilo_botao_hover.corner_radius_top_right = 5
	estilo_botao_hover.corner_radius_bottom_left = 5
	estilo_botao_hover.corner_radius_bottom_right = 5
	button_continue.add_theme_stylebox_override("hover", estilo_botao_hover)
	
	# Estilo do botão pressionado (Pressed)
	var estilo_botao_pressed = StyleBoxFlat.new()
	estilo_botao_pressed.bg_color = Color("#4A3C31") # Um pouco mais escuro
	estilo_botao_pressed.corner_radius_top_left = 5
	estilo_botao_pressed.corner_radius_top_right = 5
	estilo_botao_pressed.corner_radius_bottom_left = 5
	estilo_botao_pressed.corner_radius_bottom_right = 5
	button_continue.add_theme_stylebox_override("pressed", estilo_botao_pressed)

	# 6. DEFININDO O CONTEÚDO FINAL
	button_continue.text = "Continuar"
	label_summary.text = texto_summary # O [center] é opcional, pois o VBox pode centralizar
	
	# Conecta o sinal do botão
	button_continue.pressed.connect(_on_continue_pressed)

func _on_continue_pressed():
	hide()
