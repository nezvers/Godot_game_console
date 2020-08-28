extends CanvasLayer

onready var ConsoleScreen: = find_node("ConsoleScreen")
onready var CommandLine: = find_node("CommandLine")
onready var twean: = $Tween
onready var panel: = $PanelContainer
var NEW_LINE = '\n'
var DELIMITER = ' '

var last_commands: = ['help']
var last_command_index: = 0
var command_line_text: = ''

var commands: = {
	help = "command_help",
	echo = "command_echo",
	clear = "command_clear",
	restart = "command_restart",
	exit = "command_exit",
}

var errors: = {
	no_command = "error: command not recognized - \"%s\"",
	interpretation_fault = "error: invalid instruction - \"%s\"",
	
}


func _ready()->void:
	OS.center_window()
	CommandLine.grab_focus()
	twean.interpolate_property(panel, "rect_position:y", panel.rect_position.y, 0.0, 1.5, Tween.TRANS_QUINT, Tween.EASE_OUT)
	twean.start()
	

func _input(event:InputEvent)->void:
	if event.is_action_pressed("ui_up"):
		if !last_commands.empty():
			CommandLine.text = last_commands[last_commands.size()-1-last_command_index]
			last_command_index = (last_command_index+1) % last_commands.size()
	elif event.is_action_pressed("ui_down"):
		if !last_commands.empty():
			last_command_index = last_command_index-1
			if last_command_index <= 0:
				last_command_index = last_commands.size()
			CommandLine.text = last_commands[last_commands.size()-1-last_command_index]
	elif event.is_action_pressed("ui_cancel"):
		CommandLine.text = 'exit'
	elif event.is_action_pressed("ui_accept"):
		CommandLine_text_entered(CommandLine.text)
		last_command_index = 0
	

func CommandLine_text_entered(new_text:String)->void:
	if new_text.empty():
		return
	CommandLine.text = ''
	var error:String = parse_commands(new_text)
	ConsoleScreen.text += error + NEW_LINE

func parse_commands(text:String)->String:
	var instructions:Array = text.split(DELIMITER, false, 0)
	var error: = ''
	if commands.has(instructions[0]):
		last_commands.append(text)
		if last_commands.size() > 10:
			last_commands.remove(0)
		error = call(commands[instructions.pop_front()], instructions)
	else:
		error = errors.no_command % text
	return error


func command_help(args:Array)->String:
	var text: = ''
	var command_list: = [
		"help                - prints all command lines",
		"echo [message]      - prints given text i.e. [message] ",
		"list [type]         - returns available type instances",
		"select [index]      - selects instance from list by it's index",
		"turn [degree]       - turns selected robot to given direction",
		"move [distance]     - moves selected robot by the given distance",
		"attack              - selected robot executes attack command",
		"reflect             - selected robot reflects on life",
		"guard [on/off]      - selected robot enters / exits guard stance",
		"clear               - clears console screen",
		"restart             - restarts console",
		"exit                - exits the application"
	]
	for command in command_list:
		text += command + NEW_LINE
	return text

func command_exit(args:Array)->String:
	get_tree().quit()
	return ''

func command_echo(args:Array)->String:
	var text: = ''
	for word in args:
		text += word + DELIMITER
	return text


func command_restart(args:Array)->String:
	get_tree().reload_current_scene()
	return ''


func command_clear(args:Array)->String:
	ConsoleScreen.text = ''
	return ''
















