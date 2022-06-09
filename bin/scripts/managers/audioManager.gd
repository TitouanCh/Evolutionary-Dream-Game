extends Node2D

onready var sound = $sound
onready var music = $music

var sound_book = {}

export var muted = false

func _ready():
	AudioServer.set_bus_mute(0, muted)
	sound_book = load_sounds("res://assets/sounds")

func load_sounds(path):
	var sound_list = DataUtilities.get_all_files_dir(path)
	var key_list = DataUtilities.remove_extension(sound_list)
	
	for i in range(len(sound_list)):
		sound_book[key_list[i]] = load(path + "/" + sound_list[i])
	
	return sound_book

func play_sound(which, pitch_variation = true):
	sound.stream = sound_book[which]
	if pitch_variation: sound.pitch_scale = randf()/2 + 0.75
	else: sound.pitch_scale = 1
	sound.play()

func _on_music_finished():
	$music.play()

func _process(delta):
	if Input.is_action_just_pressed("mute"):
		muted = !muted
		AudioServer.set_bus_mute(0, muted)
