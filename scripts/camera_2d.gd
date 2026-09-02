extends Camera2D


var alvo: Node2D

func _ready() -> void:
	buscar_alvo()
	if alvo != null:
# Sem esta linha, a câmera faz um voo desde a origem no primeiro quadro.
		global_position = alvo.global_position
func _physics_process(_delta: float) -> void:
	if alvo == null:
		return
	global_position = alvo.global_position
func buscar_alvo() -> void:
	var nos := get_tree().get_nodes_in_group("player")
	if nos.is_empty():
		push_error("Camera2D: nenhum nó no grupo 'player'")
		return
	alvo = nos[0]
