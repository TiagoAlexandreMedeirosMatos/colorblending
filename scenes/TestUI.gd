extends CanvasLayer

const TEXTURE_FLAGS = Texture.FLAG_MIPMAPS | Texture.FLAG_REPEAT;

# Scenes
var maskContainerScene = preload("res://scenes/MaskContainer.tscn")

# References
var baseImageContainer: MarginContainer
var masksContainer: VBoxContainer
var outputTextureRect: TextureRect

# Values
var base_ui_size: Vector2
var base_image_ui_size: Vector2
var is_new_image
var is_node_deleted
var deleted_node

func _ready():
	baseImageContainer = $HBoxContainer/PanelContainer/VBoxContainer/VBoxContainer/BaseImageContainer
	masksContainer = $HBoxContainer/PanelContainer/VBoxContainer/VBoxContainer2/ScrollContainer/MasksContainer
	outputTextureRect = $HBoxContainer/MarginContainer/TextureRect
	
	base_ui_size = $HBoxContainer/PanelContainer.rect_size
	base_image_ui_size = $HBoxContainer/PanelContainer/VBoxContainer/VBoxContainer.rect_size
	is_new_image = false
	is_node_deleted = false
	
	baseImageContainer.connect("image_updated", self, "_on_image_updated")
	get_tree().connect("files_dropped", self, "_files_dropped")

#func _process(delta):
#	pass

func _files_dropped(files, screen):
		
	var mouse_pos = get_viewport().get_mouse_position()
	base_ui_size = $HBoxContainer/PanelContainer.rect_size
	base_image_ui_size = $HBoxContainer/PanelContainer/VBoxContainer/VBoxContainer.rect_size
	if mouse_pos.x > base_ui_size.x or mouse_pos.y > base_ui_size.y:
		return
		
	if mouse_pos.x < base_image_ui_size.x and mouse_pos.y < base_image_ui_size.y:
		is_new_image = true
		baseImageContainer.define_image(files[0])
	else:
		for file in files:
			var image = Image.new()
			image.load(file)
			if image.get_size().x != baseImageContainer.image.get_size().x or image.get_size().y != baseImageContainer.image.get_size().y:
				$AcceptDialog.popup_centered()
				return
			
			var new_mask = maskContainerScene.instance()
			masksContainer.add_child(new_mask)
			new_mask.define_image(file)
			masksContainer.get_child(masksContainer.get_child_count()-1).connect("image_updated", self, "_on_image_updated")
			masksContainer.get_child(masksContainer.get_child_count()-1).connect("image_deleted", self, "_on_image_deleted")
			
func combine_modulate():
	var base_image = Image.new()
	base_image.copy_from(baseImageContainer.image)
	var masks = []
	
	if is_new_image:
		is_new_image = false
		for child in masksContainer.get_children():
			child.queue_free()
		var img_texture = ImageTexture.new()
		img_texture.create_from_image(base_image, TEXTURE_FLAGS)
		outputTextureRect.texture = img_texture
		return
	
	var image_size = base_image.get_size()
	for mask_node in masksContainer.get_children():
		if is_node_deleted and mask_node == deleted_node:
			is_node_deleted = false
			mask_node.queue_free()
			continue
		masks.append( [mask_node.image, mask_node.color] )
	
	base_image.lock()
	for mask in masks:
		mask[0].lock()
		
	
	var base_image_pixel
	var mask_pixel
	var mask_color
	
	for y in range(0, image_size.y):
		for x in range(0, image_size.x):
			base_image_pixel = base_image.get_pixel(x,y)
			for mask in masks:
				mask_pixel = mask[0].get_pixel(x,y)
				mask_color = mask[1]
				
				if mask_pixel.r:
					base_image_pixel.r *= mask_color.r
					base_image_pixel.g *= mask_color.g
					base_image_pixel.b *= mask_color.b
			
			base_image.set_pixel(x, y, base_image_pixel)
	
	base_image.unlock()
	for mask in masks:
		mask[0].unlock()
		
	var img_texture = ImageTexture.new()
	img_texture.create_from_image(base_image, TEXTURE_FLAGS)
	outputTextureRect.texture = img_texture

func _on_image_updated():
	combine_modulate()

func _on_image_deleted(node):
	is_node_deleted = true
	deleted_node = node
	combine_modulate()