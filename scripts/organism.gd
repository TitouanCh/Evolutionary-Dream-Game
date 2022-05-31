extends KinematicBody2D

class_name Organism

var turnAccel = 10
var accel = 10
var friction = 0.95
var once = false

var belly = 0

var type

var scaleInfo = [-1, -1]

onready var body_sprite = $sprite
var neutral_sprites = []
var palette = [Color(255), Color(255), Color(255), Color(255)]

onready var collisionShape = $collisionShape

var Ttime = 0

var linear_velocity = Vector2.ZERO

var active = true

# tail object format : [Sprite : Node, [Velocity : Vector2, rotateMode : int]]
var tail = []

# whisker object format : [[points], [Velocities], function]
var whiskers = []

func set_active(state):
	active = state
	self.visible = state
	collisionShape.disabled = !state
