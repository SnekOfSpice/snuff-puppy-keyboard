@tool
extends Node
class_name SnuffPuppyKeyboardManager
## A mechanical and stupid bappy keyboard manager.
##
## Only accepts A - Z, 0 - 9, and Space as symbols to display. (Requires to set up its own input map. Use the button in the inspector to set this up, then restart the editor!)
## Enter submits the command (do with this what you will).
## Backspace deletes the input.
## No caret support.

@export_group("Display Nodes")
## Mandatory.
@export var command_line : RichTextLabel
## like a little heart or something :3 [br]
## Optional.
@export var input_prompt : Control
@export_group("Behavior")
@export_subgroup("Input", "can_input_on_")
## sets [member can_input] to this value on [method _ready].
@export var can_input_on_ready := true
## When finishing the lines pushed with [method push_text], sets [member can_input] to this value.
@export var can_input_on_lines_finished := true
@export_subgroup("Aesthetics")
## If true, backspace input will clear all of [member command_line]. If false, will go one symbol at a time.
@export var full_clear_on_backspace := true
## When finishing the lines pushed with [method push_text], clears the text in [member command_line] if true.
@export var full_clear_on_lines_finished := true
## [member input_prompt] blinks when [member can_input] is true. this is the interval!
@export_range(0.0, 10.0, 0.01) var blink_timer := 1.0
## Makes a little mechanical keyboard sfx when a button is bapped :3
@export var keyboard_sfx := true
@export_group("Plugin Stuff")
@export_tool_button("Add to Input Map", "EditorPlugin") var _input_map_action = _add_input_map

## Tracks if the keyboard currently accepts input.
var can_input := false
var _lines_to_show := []
var _line_index := 0
var _time_to_blink := blink_timer

## Emitted when the keyboard adds a symbol to [member command_line]. Not emitted when cleared.
signal symbol_added(symbol:String)
## Emitted when enter is pressed while [member can_input] is true. [param command] is the full text in [member command_line].
signal command_submitted(command:String)
## recommended to call [method set_can_input] on receiving this signal. maybe do something after receiving this like ending the day or putting a girl in a crate
signal lines_shown()
## Emitted when a key press results in input:[br]
## - Changing text, including deletion[br]
## - submitting commands[br]
## If [member keyboard_sfx] is false, you can use this to still react to valid inputs.
signal key_bapped()

const _KEYS_CMD := [
	KEY_A,
	KEY_B,
	KEY_C,
	KEY_D,
	KEY_E,
	KEY_F,
	KEY_G,
	KEY_H,
	KEY_I,
	KEY_J,
	KEY_K,
	KEY_L,
	KEY_M,
	KEY_N,
	KEY_O,
	KEY_P,
	KEY_Q,
	KEY_R,
	KEY_S,
	KEY_T,
	KEY_U,
	KEY_V,
	KEY_W,
	KEY_X,
	KEY_Y,
	KEY_Z,
]

const _KEYS_CMD_NUM := [
	KEY_1,
	KEY_2,
	KEY_3,
	KEY_4,
	KEY_5,
	KEY_6,
	KEY_7,
	KEY_8,
	KEY_9,
	KEY_0,
	KEY_SPACE,
]

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	set_can_input(can_input_on_ready)

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if can_input and input_prompt:
		_time_to_blink -= delta
		if _time_to_blink <= 0:
			var mod = input_prompt.modulate.a
			input_prompt.modulate.a = 1 if mod == 0 else 0
			_time_to_blink = blink_timer

func _unhandled_input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	if event is InputEventKey:
		if event.keycode == KEY_BACKSPACE and can_input and Input.is_action_just_pressed("ui_text_backspace"):
			if full_clear_on_backspace:
				_set_cmd_text("")
			else:
				var text = command_line.text
				text = text.erase(text.length() - 1)
				_set_cmd_text(text)
		elif event.keycode == KEY_ENTER and Input.is_action_just_pressed("ui_accept"):
			_sfx("keyboard")
			if can_input:
				emit_signal("command_submitted", command_line.text)
			else:
				if _line_index >= _lines_to_show.size() - 1:
					if full_clear_on_lines_finished:
						_set_cmd_text("")
					set_can_input(can_input_on_lines_finished)
					emit_signal("lines_shown")
				else:
					_line_index += 1
					command_line.text = _lines_to_show[_line_index]
				
		elif (Input.is_action_just_pressed("spk_cmd_input") or Input.is_action_just_pressed("spk_cmd_input_num")) and can_input:
			var label:String = OS.get_keycode_string(event.get_key_label_with_modifiers())
			label = label.trim_prefix("Shift+")
			label = label.trim_prefix("Ctrl+")
			label = label.trim_prefix("Alt+")
			if label in ["1","2","3","4","5","6","7","8","9","0","Space", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]:
				if label == "Space":
					label = " "
				emit_signal("symbol_added", label)
				_set_cmd_text(command_line.get_parsed_text() + label)

func _set_cmd_text(text:String):
	command_line.text = text
	_sfx("keyboard")

## Push a set of lines to display. They will replace whatever is currently written in [member command_line] and can be advanced through with enter.
## See [signal lines_shown].
func push_text(lines:Array):
	if lines.is_empty():
		return
	set_can_input(false)
	_line_index = 0
	_lines_to_show = lines
	command_line.text = _lines_to_show[0]

## Sets if the keyboard currently accepts input.
func set_can_input(value:bool):
	can_input = value
	
	if can_input:
		command_line.text = ""
	
	if input_prompt:
		input_prompt.modulate.a = 1 if can_input else 0
	_time_to_blink = blink_timer

func _sfx(file_name:String):
	emit_signal("key_bapped")
	if not keyboard_sfx:
		return
	var path := str("res://addons/snuff-puppy-keyboard/sounds/sfx/", file_name, ".wav")
	if not FileAccess.file_exists(path):
		push_warning(str(file_name, ".wav doesn't exist"))
	
	var player = AudioStreamPlayer.new()
	add_child(player)
	player.stream = load(path)
	player.play()
	player.pitch_scale = randf_range(0.57, (1.0 / 0.75))
	player.finished.connect(player.queue_free)



func _add_input_map():
	# cmd_input
	# all letters
	var events_cmd := []
	for kc in _KEYS_CMD:
		var e =  InputEventKey.new()
		e.keycode = kc
		e.physical_keycode = kc
		events_cmd.append(e)
	ProjectSettings.set_setting(
		"input/spk_cmd_input",
		{
			"deadzone" : 0.5,
			"events" : events_cmd
		}
	)
	
	# cmd_input_num
	# all numbers and space
	var events_cmd_num := []
	for kc in _KEYS_CMD_NUM:
		var e =  InputEventKey.new()
		e.keycode = kc
		e.physical_keycode = kc
		events_cmd_num.append(e)
	ProjectSettings.set_setting(
		"input/spk_cmd_input_num",
		{
			"deadzone" : 0.5,
			"events" : events_cmd_num
		}
	)
	print_rich("[color=#f16af2]Restart the editor <3[/color]")
	ProjectSettings.save()
