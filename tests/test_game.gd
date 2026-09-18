extends SceneTree

var failures := 0


func _init() -> void:
	call_deferred("_run")


func _check(condition: bool, label: String) -> void:
	if not condition:
		failures += 1
		push_error("FEHLER: " + label)


func _run() -> void:
	seed(12345)
	var main: Node2D = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await physics_frame

	var player: Node2D = main.get_node("Player")
	_check(main.pickups.size() == main.pickup_count, "Startanzahl Pickups")
	_check(main.hazards.size() == main.hazard_count, "Startanzahl Gefahren")
	_check(main.score == 0 and main.running, "Startzustand")

	player.position = main.pickups[0].position
	await physics_frame
	_check(main.score == 1, "Punkt nach Einsammeln")
	_check(main.pickups.size() == main.pickup_count, "Pickup wird nachgeliefert")

	player.position = main.hazards[0].position + Vector2(25.0, 0.0)
	await physics_frame
	_check(not main.running, "Runde endet bei sichtbarer Berührung")
	_check(main.get_node("UI/RestartButton").visible, "Neustart-Knopf sichtbar")

	main.call("_start_round")
	_check(main.running and main.score == 0, "Neustart setzt Runde zurück")
	for pickup in main.pickups:
		_check(pickup.position.distance_to(player.position) >= 90.0, "Pickup spawn frei vom Spieler")
	for hazard in main.hazards:
		_check(hazard.position.distance_to(player.position) >= 90.0, "Gefahr spawn frei vom Spieler")

	if failures == 0:
		print("test_game: OK")
	quit(1 if failures > 0 else 0)
