extends Control

# Intro scene for Chaos Observatory

func _ready():
	$VBoxContainer/Title.text = "CHAOS OBSERVATORY"
	$VBoxContainer/Subtitle.text = "Calibration Protocol v1.0"
	$VBoxContainer/Description.text = """Welcome, Researcher.

You are about to calibrate the Observatory's Field Simulation.

Your precision in the early calibration steps will dramatically affect the final outcome.

Small changes in initial conditions lead to vastly different worlds.

This is the essence of chaos.

Press START to begin."""
	
	if $VBoxContainer/StartButton:
		$VBoxContainer/StartButton.text = "START CALIBRATION"
