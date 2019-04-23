extends MarginContainer

const TEXTURE_FLAGS = Texture.FLAG_MIPMAPS | Texture.FLAG_REPEAT;

signal image_updated

# References
var textureRect: TextureRect
var label: Label

# Variables
var image: Image
var image_name: String

func _ready():
	textureRect = $PanelContainer/MarginContainer/MaskBox/HBoxContainer/TextureRect
	label = $PanelContainer/MarginContainer/MaskBox/HBoxContainer/Label
	
	image = Image.new()

func define_image(path: String):
	image_name = path
	image.load(path)
	
	var imageTexture = ImageTexture.new()
	imageTexture.create_from_image(image, TEXTURE_FLAGS)
	textureRect.texture = imageTexture
	var temp = image_name.split('\\')
	label.text = temp[len(temp)-1]
	emit_signal('image_updated')