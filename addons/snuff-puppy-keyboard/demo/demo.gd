extends Control

const COMMANDS :=[
	"ABOUT",
	"LOVE",
	"QUIT",
	"I LOVE YOU",
	"I HATE YOU",
]
var last_command : String

@onready var kbmanager : SnuffPuppyKeyboardManager = $SnuffPuppyKeyboardManager

func _on_snuff_puppy_keyboard_manager_command_submitted(command: String) -> void:
	if last_command == "LOVE":
		if command == "i love you".to_upper():
			kbmanager.push_text([
				"[color=#f16af2]<3[/color]",
			])
		elif command == "i hate you".to_upper():
			kbmanager.push_text([
				"[color=red]Fuck you.[/color]",
			])
		else:
			kbmanager.push_text([
				"I asked you a question.",
				"Mutt.",
				"Answer either \"I LOVE YOU\" or \"I HATE YOU\".",
			])
			return
	
	if not command in COMMANDS:
		kbmanager.push_text([
			"Invalid command.",
			"Stupid mutt."
		])
		return
	
	match command:
		"ABOUT":
			kbmanager.push_text([
				"Snuff Puppy Shelter is a small game on itch.io",
				"The keyboard there is really stupid",
				"This is that keyboard in plugin form for you to use!",
				"The keyboard hates you.",
				"The game hates you.",
				"You would make such a pretty corpse <3"
			])
		"LOVE":
			kbmanager.push_text([
				"Do you love me?",
				"Answer either \"I LOVE YOU\" or \"I HATE YOU\".",
			])
		"QUIT":
			kbmanager.push_text([
				"Have fun with the puppy keyboard :3"
			])
	
	last_command = command


func _on_snuff_puppy_keyboard_manager_lines_shown() -> void:
	if last_command == "QUIT" or last_command == "I HATE YOU":
		get_tree().quit()
