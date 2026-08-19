@tool
extends Camera3D

@export var mouseSensitivity: float = 0.005
@export var minPitching: float = -89.0
@export var maxPitching: float = 89.0
@export var pitch: float = 0.0

@export_category("Cam Shaking")
@export var shakeAmount: float = 0.15
@export var shakeSpeed: float = 8.0
@export var shakeSmoothness: float = 20.5

@export var player: CharacterBody3D

var CamShakeTime: float = 0.0
var originalPos: Vector3
var originalRotation: Vector3

func _validate_property(property: Dictionary) -> void:
	if (property.name == "maxPitching"):
		property.usage &= ~PROPERTY_USAGE_EDITOR

	if (property.name == "pitch"):
		property.usage &= ~PROPERTY_USAGE_EDITOR


func _ready() -> void:
	originalPos = position
	originalRotation = rotation
	
	if (not Engine.is_editor_hint()):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(delta: float) -> void:
	if (Engine.is_editor_hint()):
		return
	
	CameraShake(delta)

func _input(event: InputEvent) -> void:
	if (event is InputEventKey):
		if (event.pressed and event.keycode == KEY_ESCAPE):
			if (Input.mouse_mode == Input.MOUSE_MODE_CAPTURED):
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			else:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			return
	
	if (event is InputEventMouseMotion):
		if (Input.mouse_mode == Input.MOUSE_MODE_CAPTURED):
			rotateCamera(event.relative)

func rotateCamera(mouseDelta: Vector2) -> void:
	rotation.y -= mouseDelta.x * mouseSensitivity
	
	pitch -= mouseDelta.y * mouseSensitivity
	pitch = clamp(pitch, deg_to_rad(minPitching), deg_to_rad(maxPitching))
	
	rotation.x = pitch

func CameraShake(delta: float) -> void:
	if (player == null):
		return
	
	var horizontalVel := Vector2(player.velocity.x, player.velocity.z)
	var isMoving := horizontalVel.length_squared() > 0.01
	
	var isGrounded = player.is_on_floor()
	
	if (isMoving and isGrounded):
		CamShakeTime += delta * shakeSpeed
		
		var bbX = sin(CamShakeTime) * shakeAmount
		var bbY = abs(cos(CamShakeTime)) * shakeAmount
		
		var targetPos := originalPos
		targetPos.x += bbX
		targetPos.y += bbY
		
		position = targetPos
		
	else:
		position = originalPos
		
	rotation.x = pitch
	rotation.z = originalRotation.z
