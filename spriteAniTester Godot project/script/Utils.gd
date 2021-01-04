extends Node
class_name Utils


func _ready() -> void:
	pass 

static func debugPrint(s:String):
	if ViewConstants.DEBUGGING:
		print(s)
