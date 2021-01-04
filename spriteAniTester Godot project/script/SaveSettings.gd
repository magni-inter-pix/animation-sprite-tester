extends Node

var savegame = File.new() 
var save_path = "user://spriteAniTester.save" 
var save_data

var fps:int  setget _setFps#= ViewConstants.DEFAULT_FPS
var bgColor:String setget _setBgColor #= ViewConstants.DEFAULT_BG_COLOR 
var directory:String setget _setDirectory

func _init():
	Utils.debugPrint("_ready save settings")
	if savegame.file_exists(save_path):
		Utils.debugPrint("savegame.file_exists")
		read_savegame()
	else:
		createSaveWithDefaults()
		
func _ready() -> void:
	pass 
	
func createSaveWithDefaults():
	defaults()
	Utils.debugPrint("createSaveWithDefaults done")

func create_save(): 
	savegame.open(save_path, File.WRITE) 
	savegame.store_line(to_json(save_data)) 
	savegame.close()
	Utils.debugPrint("create_save done")
	
func defaults():
	save_data = {ViewConstants.DIRECTORY: "", ViewConstants.FPS:"", ViewConstants.BG_COLOR:"" }
	_setFps(ViewConstants.DEFAULT_FPS)
	_setBgColor(ViewConstants.DEFAULT_BG_COLOR)
	Utils.debugPrint("defaults:"+ str(save_data))

func read_savegame(): 
	savegame.open(save_path, File.READ)
	save_data = parse_json(savegame.get_as_text()) 
	savegame.close()
	var sSaveData= str(save_data)
	Utils.debugPrint("save_data:" + sSaveData)

	if sSaveData == "Null":
		Utils.debugPrint("createSaveWithDefaults")
		createSaveWithDefaults()
	else:
		if save_data.has(ViewConstants.DIRECTORY):
			directory = save_data[ViewConstants.DIRECTORY]
		if save_data.has(ViewConstants.FPS):
			fps = save_data[ViewConstants.FPS]
		if save_data.has(ViewConstants.BG_COLOR):
			bgColor = save_data[ViewConstants.BG_COLOR]

func _setFps(new_value):
	fps = new_value
	save_data[ViewConstants.FPS] = fps
	create_save()
	
func _setDirectory(new_value):
	directory = new_value
	save_data[ViewConstants.DIRECTORY] = directory
	create_save()
	
func _setBgColor(new_value):
	bgColor = new_value
	save_data[ViewConstants.BG_COLOR] = bgColor
	create_save()
