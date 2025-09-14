extends PopupPanel

# --- Variáveis ---
@export var background_texture: Texture2D # Arraste a imagem do pergaminho aqui no Inspetor

# Referências para os nós na estrutura correta
@onready var title_label = $MarginContainer/CenterContainer/VBoxContainer/TitleLabel
@onready var body_label = $MarginContainer/CenterContainer/VBoxContainer/BodyLabel
@onready var result_label = $MarginContainer/CenterContainer/VBoxContainer/ResultLabel
@onready var button_continue = $MarginContainer/CenterContainer/VBoxContainer/Button

func set_summary_texts(title: String, body: String, result: String):
	title_label.text = title
	body_label.text = body
	result_label.text = result


func _ready():
	var fonte_pixel = load("res://assets/font/PixeloidSans-mLxMm.ttf")
	
	self.min_size = Vector2(500, 600)
	var margin_container = $MarginContainer
	margin_container.add_theme_constant_override("margin_left", 35)
	margin_container.add_theme_constant_override("margin_right", 35)
	margin_container.add_theme_constant_override("margin_top", 40)
	margin_container.add_theme_constant_override("margin_bottom", 40)
	
	var vbox_container = $MarginContainer/CenterContainer/VBoxContainer
	vbox_container.add_theme_constant_override("separation", 20)

	title_label.add_theme_font_override("font", fonte_pixel)
	title_label.add_theme_font_size_override("font_size", 28)
	title_label.add_theme_font_size_override("outline_size", 3)
	title_label.add_theme_color_override("font_outline_color", Color.BLACK)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	body_label.add_theme_font_override("font", fonte_pixel)
	body_label.add_theme_font_size_override("font_size", 18)
	body_label.add_theme_font_size_override("outline_size", 2)
	body_label.add_theme_color_override("font_outline_color", Color.BLACK)
	body_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	result_label.add_theme_font_override("font", fonte_pixel)
	result_label.add_theme_font_size_override("font_size", 20)
	result_label.add_theme_font_size_override("outline_size", 2)
	result_label.add_theme_color_override("font_outline_color", Color.BLACK)
	result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	button_continue.add_theme_font_override("font", fonte_pixel)
	button_continue.add_theme_font_size_override("font_size", 16)
	button_continue.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button_continue.text = "Continuar"

	var estilo_botao_normal = StyleBoxFlat.new()
	estilo_botao_normal.bg_color = Color("#5C4A3E")
	estilo_botao_normal.set_corner_radius_all(5)
	estilo_botao_normal.content_margin_left = 20
	estilo_botao_normal.content_margin_right = 20
	estilo_botao_normal.content_margin_top = 10
	estilo_botao_normal.content_margin_bottom = 10
	button_continue.add_theme_stylebox_override("normal", estilo_botao_normal)

	var estilo_botao_hover = StyleBoxFlat.new()
	estilo_botao_hover.bg_color = Color("#7D6B5D")
	estilo_botao_hover.set_corner_radius_all(5)
	estilo_botao_hover.content_margin_left = 20
	estilo_botao_hover.content_margin_right = 20
	estilo_botao_hover.content_margin_top = 10
	estilo_botao_hover.content_margin_bottom = 10
	button_continue.add_theme_stylebox_override("hover", estilo_botao_hover)
	
	var estilo_botao_pressed = StyleBoxFlat.new()
	estilo_botao_pressed.bg_color = Color("#4A3C31")
	estilo_botao_pressed.set_corner_radius_all(5)
	estilo_botao_pressed.content_margin_left = 20
	estilo_botao_pressed.content_margin_right = 20
	estilo_botao_pressed.content_margin_top = 10
	estilo_botao_pressed.content_margin_bottom = 10
	button_continue.add_theme_stylebox_override("pressed", estilo_botao_pressed)
	
	if background_texture:
		var estilo_painel = StyleBoxTexture.new()
		estilo_painel.texture = background_texture
		estilo_painel.texture_margin_left = 40.0
		estilo_painel.texture_margin_right = 40.0
		estilo_painel.texture_margin_top = 40.0
		estilo_painel.texture_margin_bottom = 40.0
		add_theme_stylebox_override("panel", estilo_painel)
	else:
		var estilo_painel_fallback = StyleBoxFlat.new()
		estilo_painel_fallback.bg_color = Color("#3B3029")
		add_theme_stylebox_override("panel", estilo_painel_fallback)
	button_continue.pressed.connect(_on_button_pressed)


func _on_button_pressed():
	hide()
