extends Control

@onready var progress_bar: ProgressBar = $ProgressBar


func timer(timer_max_value):
	progress_bar.max_value = timer_max_value
	progress_bar.value = timer_max_value

func set_time_value(time_value):
	progress_bar.value = time_value
