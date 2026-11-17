class_name PerfilPerfeito
extends Perfil
## Joga a silaba certa sempre que tem; senao troca a mao (D-17).


func _init() -> void:
	nome = "perfeito"


func decidir(partida: Partida, _rng: RandomNumberGenerator) -> Dictionary:
	var j := _jogada_certa(partida)
	if j.is_empty():
		return {"acao": "trocar"}
	return j
