extends CharacterBody3D

@export var baseSpeed: float = 7.0
@export var playerAcceleration: float = 60.0
@export var PlayerDeceleration: float = 55.0
@export var JumpingGravitationalSpeed: float = 15.0;
@export var camera: Camera3D

@export_category("Player Dash")
@export var dashSpeed: float = 25.0
@export var dashDuration: float = 0.2
@export var dashCooldown: float = 0.8

var isDashing: bool = false
var dashTimer: float = 0.0
var dashCoolDownTimer: float = 0.0
var dashDirection := Vector3.ZERO

var EarthGravity: float = 20.5

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	var moveInput := Vector2.ZERO
	
	if (Input.is_key_pressed(KEY_A)):
		moveInput.x -= 1.0
	if (Input.is_key_pressed(KEY_D)):
		moveInput.x += 1.0
	if (Input.is_key_pressed(KEY_W)):
		moveInput.y -= 1.0
	if (Input.is_key_pressed(KEY_S)):
		moveInput.y += 1.0
	
	if (moveInput.length() > 1.0):
		moveInput = moveInput.normalized()
		
	var direction := Vector3.ZERO
	
	if (camera != null):
		var forward := -camera.global_transform.basis.z
		var right := camera.global_transform.basis.x
		
		forward.y = 0
		right.y = 0
		
		forward = forward.normalized()
		right = right.normalized()
		
		direction = right * moveInput.x + forward * -moveInput.y
	
	if (dashCoolDownTimer > 0.0):
		dashCoolDownTimer -= delta

	if (Input.is_key_pressed(KEY_SHIFT) and not isDashing):
		if (dashCoolDownTimer <= 0.0):
			Dash(direction)
	
	if (isDashing):
		dashTimer -= delta
		
		velocity.x = dashDirection.x * dashSpeed
		velocity.z = dashDirection.z * dashSpeed
		
		if (dashTimer <= 0.0):
			isDashing = false
	
	if (not isDashing):
		var targetVel := direction * baseSpeed
		
		if (direction.length() > 0):
			var accDelt = playerAcceleration * delta
			
			velocity.x = move_toward(velocity.x, targetVel.x, accDelt)
			velocity.z = move_toward(velocity.z, targetVel.z, accDelt)
			
		else: 
			var DetDelt = PlayerDeceleration * delta
			
			velocity.x = move_toward(velocity.x, 0.0, DetDelt)
			velocity.z = move_toward(velocity.z, 0.0, DetDelt)

	if (not is_on_floor()):
		velocity.y -= EarthGravity * delta
		
	else:
		velocity.y = 0
		
		if (Input.is_key_pressed(KEY_SPACE)):
			Jump()
	
	move_and_slide()

func Jump() -> void:
	velocity.y = JumpingGravitationalSpeed

func Dash(direction: Vector3) -> void:
	if (direction.length_squared() > 0.0):
		dashDirection = direction.normalized()
		
	else:
		dashDirection = -global_transform.basis.z
		dashDirection.y = 0.0
		dashDirection = dashDirection.normalized()
	
	isDashing = true
	dashTimer = dashDuration
	dashCoolDownTimer = dashCooldown
	
	velocity = Vector3.ZERO
	velocity.x = dashDirection.x * dashSpeed
	velocity.z = dashDirection.z * dashSpeed
