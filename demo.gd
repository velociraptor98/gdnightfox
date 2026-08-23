@tool
class_name NightfoxDemo
extends Node2D
## Doc comment: every token type below maps to a different `.tet` color key.
## Use this file to eyeball a theme — if a color looks wrong, it's the key named here.

# Regular comment. Comment markers get their own colors:
# TODO: warning marker      NOTE: notice marker      CRITICAL: critical marker

signal health_changed(amount: int)

enum State { IDLE, RUNNING, DEAD }

const MAX_SPEED: float = 320.5          # number_color
const TAG := &"player"                  # gdscript/string_name_color
const SCENE_PATH := ^"res://demo.tscn"  # gdscript/node_path_color

@export var speed: float = 120.0        # gdscript/annotation_color
@export_range(0, 100) var health: int = 100

@onready var _sprite: Node = $Sprite2D  # member_variable_color

static var instances: int = 0

var _state: State = State.IDLE
var _label: String = "hello %s and {name}"   # string / string_placeholder
var _tint: Color = Color(0.44, 0.61, 0.84, 1.0)   # engine_type_color


func _ready() -> void:                  # gdscript/function_definition_color
	instances += 1
	print("ready: ", TAG)               # gdscript/global_function_color
	_apply(_state)


func _physics_process(delta: float) -> void:
	# control_flow_keyword_color: if / elif / else / for / while / match / return
	if health <= 0:
		_state = State.DEAD
		return
	elif health < 25:
		_state = State.IDLE
	else:
		_state = State.RUNNING

	for i in range(3):
		if i == 2:
			continue
		speed = clampf(speed + delta, 0.0, MAX_SPEED)

	while speed > MAX_SPEED:
		speed -= 1.0
		break

	match _state:
		State.IDLE:
			pass
		State.RUNNING:
			position += Vector2.RIGHT * speed * delta
		_:
			push_warning("unhandled state")


func _apply(state: State) -> Dictionary:
	var data := {
		"state": state,
		"speed": speed,
		"tag": TAG,
	}
	var ok: bool = data.has("state") and not data.is_empty()
	assert(ok, "data must not be empty")
	return data
