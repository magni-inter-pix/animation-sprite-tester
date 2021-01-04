extends Node2D

onready var fileDialog = $btnOpenDir/FileDialog
onready var btnPlay = $btnPlay
onready var btnOpenDir = $btnOpenDir
onready var spinBoxFrameRate = $SpinBoxFrameRate
onready var animatedSprite = $AnimatedSprite
onready var txtDirPath:LineEdit = $txtDirPath
onready var colorRect = $ColorRect
onready var colorSelectDialog = $colorSelectDialog
onready var colorPicker = $colorSelectDialog/ColorPicker
onready var btnAbout = $btnAbout
onready var aboutPopup = $btnAbout/aboutPopup
onready var txtAbout:RichTextLabel = $btnAbout/aboutPopup/RichTextLabel

var firstImage:Image
var bFirstImage:bool
var dirPath:String

var frameFileNameArray:Array = []
var frameArray:Array = []

const ANIM = "anim"
const IMAGE_MARGIN_LEFT = 100
const IMAGE_MARGIN_TOP = 40

var spriteFrames:SpriteFrames

func _ready() -> void:
	get_tree().root.connect("size_changed", self, "_on_viewport_size_changed")
	spriteFrames = animatedSprite.frames
	
	txtDirPath.margin_right = get_viewport().size.x -5 #- IMAGE_MARGIN_LEFT
	resizeWindow()
	aboutPopup.window_title = "About"
	
	colorPicker.color = Color(SaveSettings.bgColor)
	colorRect.color = Color(SaveSettings.bgColor)
	if SaveSettings.directory != "":	
		txtDirPath.text = SaveSettings.directory
		_on_FileDialog_dir_selected(SaveSettings.directory)
	spinBoxFrameRate.value = SaveSettings.fps

	Utils.debugPrint("SaveSettings.bgColor"+ str(SaveSettings.bgColor))
	
	txtAbout.bbcode_text = txtAbout.bbcode_text + "\nVersion: " + ViewConstants.VERSION
	

func resizeWindow():
	txtDirPath.margin_right = get_viewport().size.x -5
	btnAbout.margin_bottom = get_viewport().size.y -5
	btnAbout.margin_top = get_viewport().size.y -25
	
func _on_btnOpenDir_pressed() -> void:
	var directory = Directory.new()
	var dirExists = directory.dir_exists(txtDirPath.text)
	if dirExists:
		fileDialog.current_path = txtDirPath.text
	Utils.debugPrint("bgColorPopupped:popup")
	fileDialog.popup_centered()
	
func _on_txtDirPath_text_changed(new_text: String) -> void:
	Utils.debugPrint("_on_txtDirPath_text_changed"+ new_text[new_text.length()-1])
	checkAndCorrectLastDirChar()
	
func checkAndCorrectLastDirChar():
	var lastDirChar:String = txtDirPath.text[txtDirPath.text.length()-1]
	if  lastDirChar != "\\" and lastDirChar != "/":
		txtDirPath.text = txtDirPath.text + "/"
		
func stopAnimation():
	animatedSprite.stop()
	btnPlay.text = "Play"
	
func _on_btnPlay_pressed() -> void:
	if animatedSprite.is_playing():
		stopAnimation()
	else:
		playAnimation()

func _on_FileDialog_dir_selected(sDir: String) -> void:
	txtDirPath.text = sDir
	SaveSettings.directory = sDir
	dirPath = sDir
	frameFileNameArray = []
	var dir = Directory.new()
	if dir.open(sDir) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
					Utils.debugPrint("Found directory: " + file_name)
			else:
				Utils.debugPrint("Found file: " + file_name)
				if file_name.get_extension() == "png":
					frameFileNameArray.push_back(file_name)
			file_name = dir.get_next()
	else:
		Utils.debugPrint("An error occurred when trying to access the path.")
	#if bFirstImage == false: #image was added
	addSpriteFrames()
	checkAndCorrectLastDirChar()
	
func addSpriteFrames():
	frameFileNameArray.sort()
	frameArray = []
	bFirstImage = true
	for frameFileName  in frameFileNameArray:
		var image:Image = Image.new()
		image.load(dirPath + "/" +frameFileName)
		if bFirstImage:
			firstImage = image
		var imageTexture = ImageTexture.new()
		imageTexture.create_from_image(image)
		frameArray.push_back(imageTexture)
		if bFirstImage:
			colorRect.margin_right = firstImage.get_width() + IMAGE_MARGIN_LEFT
			colorRect.margin_bottom = firstImage.get_height() + IMAGE_MARGIN_TOP
		bFirstImage = false
		Utils.debugPrint("png added")
	
	spriteFrames.clear(ANIM)
	for texture in frameArray:
		spriteFrames.add_frame(ANIM, texture)
	animatedSprite.frames = spriteFrames
	playAnimation()

func playAnimation(backwards:bool=false):
	spriteFrames.set_animation_speed(ANIM,SaveSettings.fps)
	animatedSprite.play(ANIM,backwards)
	btnPlay.text = "Stop"

func _on_btnOpenFiles_pressed() -> void:
	#not yet
	pass

func _on_btnAbout_pressed() -> void:
	aboutPopup.popup()

func _on_btnColorBg_pressed() -> void:
	if colorSelectDialog.visible:
		colorSelectDialog.hide()
	else:
		colorSelectDialog.show()

func _on_ColorPicker_color_changed(color: Color) -> void:
	colorRect.color = color
	SaveSettings.bgColor = color.to_html()
	Utils.debugPrint(str(color.to_html()))

func _on_viewport_size_changed()-> void:
	resizeWindow()

func _on_SpinBoxFrameRate_value_changed(value: float) -> void:
	SaveSettings.fps = spinBoxFrameRate.value
	spriteFrames.set_animation_speed(ANIM,SaveSettings.fps)

func _on_btnNextFrame_pressed() -> void:
	_advanceFrame(1)
	 
func _on_btnPrevFrame_pressed() -> void:
	_advanceFrame(-1)
	
func _advanceFrame(number:int):
	stopAnimation()
	var numFrames = spriteFrames.get_frame_count(ANIM)
	var currentFrame = animatedSprite.frame
	currentFrame = (currentFrame + number + numFrames) % numFrames
	animatedSprite.frame = currentFrame

func _on_btnPlaybackwards_pressed() -> void:
	playAnimation(true)
