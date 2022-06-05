extends Node2D

var eat = preload("res://sounds/eat.wav")
var knock = preload("res://sounds/knock.wav")

func play_knock():
	$sound.stream = knock
	$sound.pitch_scale = randf()/2 + 0.75
	$sound.play()

func play_eat():
	$sound.stream = eat
	$sound.pitch_scale = randf()/2 + 0.75
	$sound.play()

func _on_music_finished():
	$music.play()
