extends Node3D

func _ready() -> void:
	pass 
	
func _process(delta: float) -> void:
	$"WorldEnvironment_(GlobalVolume)".environment.sky_rotation.y += 0.0002
	if ($"WorldEnvironment_(GlobalVolume)".environment.sky_rotation.y >= 360):
		$"WorldEnvironment_(GlobalVolume)".environment.sky_rotation.y = 0
