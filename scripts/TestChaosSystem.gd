extends Node

# Test script to verify FieldManager and chaos system
# Run this in a standalone scene to test the core logic

func _ready():
	print("\n=== CHAOS OBSERVATORY SYSTEM TEST ===\n")
	
	test_determinism()
	test_sensitivity()
	test_all_endings()
	test_weighting()
	
	print("\n=== ALL TESTS COMPLETE ===\n")

func test_determinism():
	print("TEST 1: Determinism (identical inputs → identical outputs)")
	
	# Run 1
	FieldManager.reset_all()
	simulate_playthrough([0.8, 0.7, 0.9, 0.6, 0.5, 0.4, 0.3, 0.2, 0.1, 0.5])
	var result1 = FieldManager.evolve_field()
	var ending1 = FieldManager.determine_ending(result1)
	
	# Run 2 (identical)
	FieldManager.reset_all()
	simulate_playthrough([0.8, 0.7, 0.9, 0.6, 0.5, 0.4, 0.3, 0.2, 0.1, 0.5])
	var result2 = FieldManager.evolve_field()
	var ending2 = FieldManager.determine_ending(result2)
	
	if ending1 == ending2 and result1 == result2:
		print("✓ PASS: Determinism verified")
	else:
		print("✗ FAIL: Non-deterministic behavior detected!")
	
	print("  Ending: " + ending1)
	print()

func test_sensitivity():
	print("TEST 2: Sensitivity to Initial Conditions")
	
	# Early task change
	FieldManager.reset_all()
	simulate_playthrough([0.80, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5])
	var result_a = FieldManager.evolve_field()
	var ending_a = FieldManager.determine_ending(result_a)
	
	FieldManager.reset_all()
	simulate_playthrough([0.20, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5])
	var result_b = FieldManager.evolve_field()
	var ending_b = FieldManager.determine_ending(result_b)
	
	print("  High Task 1 → " + ending_a)
	print("  Low Task 1  → " + ending_b)
	
	if ending_a != ending_b:
		print("✓ PASS: Early tasks have strong influence")
	else:
		print("⚠ WARNING: Early task change didn't affect ending")
	
	# Late task change
	FieldManager.reset_all()
	simulate_playthrough([0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.80])
	var result_c = FieldManager.evolve_field()
	var ending_c = FieldManager.determine_ending(result_c)
	
	FieldManager.reset_all()
	simulate_playthrough([0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.20])
	var result_d = FieldManager.evolve_field()
	var ending_d = FieldManager.determine_ending(result_d)
	
	print("  High Task 10 → " + ending_c)
	print("  Low Task 10  → " + ending_d)
	
	if ending_c == ending_d:
		print("✓ PASS: Late tasks have weak influence")
	else:
		print("⚠ NOTE: Late task affected ending (rare but possible)")
	
	print()

func test_all_endings():
	print("TEST 3: Ending Reachability")
	
	var strategies = {
		"harmonic_garden": [1.0, 1.0, 1.0, 1.0, 0.8, 0.7, 0.6, 0.5, 0.4, 0.3],
		"storm_spiral": [0.0, 0.0, 0.1, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7],
		"frozen_collapse": [0.2, 0.1, 0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7],
		"runaway_bloom": [0.8, 0.9, 0.7, 0.6, 0.5, 0.4, 0.3, 0.2, 0.1, 0.0],
		"stable_equilibrium": [0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5],
	}
	
	for ending_name in strategies.keys():
		FieldManager.reset_all()
		simulate_playthrough(strategies[ending_name])
		var result = FieldManager.evolve_field()
		var actual_ending = FieldManager.determine_ending(result)
		
		if actual_ending == ending_name:
			print("  ✓ " + ending_name)
		else:
			print("  ⚠ " + ending_name + " → got " + actual_ending)
	
	print()

func test_weighting():
	print("TEST 4: Weight System")
	
	print("  Task weights: " + str(FieldManager.weights))
	
	# Verify Task 1 has more impact than Task 10
	var weight_ratio = FieldManager.weights[1] / FieldManager.weights[10]
	print("  Task 1/Task 10 ratio: %.2fx" % weight_ratio)
	
	if weight_ratio > 3.0:
		print("✓ PASS: Strong early-task weighting")
	else:
		print("✗ FAIL: Insufficient weight difference")
	
	print()

func simulate_playthrough(performance_metrics: Array):
	# performance_metrics = array of 10 floats (0.0 to 1.0)
	# representing success in each task
	
	for i in range(10):
		var task_index = i + 1
		var success = performance_metrics[i]
		
		# Generate generic delta based on success
		var delta = {
			"order": (success - 0.5) * 0.5,
			"stability": (success - 0.5) * 0.4,
			"entropy": (0.5 - success) * 0.3,
			"momentum": (success - 0.5) * 0.3,
			"growth_pressure": (success - 0.5) * 0.2,
			"oscillation": (success - 0.5) * 0.2
		}
		
		FieldManager.apply_task_delta(task_index, delta)

func print_field_state():
	print("  Order: %.3f" % FieldManager.order)
	print("  Stability: %.3f" % FieldManager.stability)
	print("  Entropy: %.3f" % FieldManager.entropy)
	print("  Momentum: %.3f" % FieldManager.momentum)
	print("  Growth Pressure: %.3f" % FieldManager.growth_pressure)
	print("  Oscillation: %.3f" % FieldManager.oscillation)
