extends MarginContainer

const TEXTURE_FLAGS = Texture.FLAG_MIPMAPS | Texture.FLAG_REPEAT;

signal image_updated
signal image_deleted

# References
var rgbContainer: MarginContainer
var rSlider: HSlider
var gSlider: HSlider
var bSlider: HSlider
var colorBox: ColorRect
var textureRect: TextureRect
var label: Label

# Variables
var color: Color
var image: Image = Image.new()
var image_name: String

func _ready():
	rgbContainer = $VBoxContainer/RGBContainer
	rSlider = $VBoxContainer/RGBContainer/PanelContainer2/MarginContainer/RGBBox/GridContainer/RedSlider
	gSlider = $VBoxContainer/RGBContainer/PanelContainer2/MarginContainer/RGBBox/GridContainer/GreenSlider
	bSlider = $VBoxContainer/RGBContainer/PanelContainer2/MarginContainer/RGBBox/GridContainer/BlueSlider
	colorBox = $VBoxContainer/RGBContainer/PanelContainer2/MarginContainer/RGBBox/ColorRect
	textureRect = $VBoxContainer/PanelContainer/MarginContainer/MaskBox/HBoxContainer/TextureRect
	label = $VBoxContainer/PanelContainer/MarginContainer/MaskBox/HBoxContainer/Label
	
	
	rSlider.connect("value_changed", self, "_on_Slider_value_changed")
	gSlider.connect("value_changed", self, "_on_Slider_value_changed")
	bSlider.connect("value_changed", self, "_on_Slider_value_changed")
	
	color = Color(1,1,1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_TextureButton_toggled(button_pressed):
	rgbContainer.visible = !button_pressed

func update_rect_color():
	color = Color(rSlider.value, gSlider.value, bSlider.value)
	colorBox.color = color
	emit_signal("image_updated")

func _on_Slider_value_changed(value: float):
	update_rect_color()
	
func define_image(path: String):
	image_name = path
	image.load(path)
	
	var imageTexture = ImageTexture.new()
	imageTexture.create_from_image(image, TEXTURE_FLAGS)
	textureRect.texture = imageTexture
	var temp = image_name.split('\\')
	label.text = temp[len(temp)-1]
	emit_signal("image_updated")

func _on_DeleteButton_pressed():
	emit_signal("image_deleted", self)
