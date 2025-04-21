@tool
extends EditorPlugin

func _enter_tree() -> void:
	add_custom_type(
		"SnuffPuppyKeyboardManager",
		"Node",
		preload("res://addons/snuff-puppy-keyboard/src/snuff_puppy_keyboard.gd"),
		preload("res://addons/snuff-puppy-keyboard/visuals/paws.png")
	)
