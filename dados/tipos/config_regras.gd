class_name ConfigRegras
extends Resource
## Alavancas de regra do Cofre Magico. Nunca usar constantes de codigo para estes valores.

@export var tamanho_mao: int = 5
@export var silabas_por_turno: int = 1
## 0 = mao inteira; N>0 = devolve N cartas sorteadas da mao.
@export var cartas_por_troca: int = 0
@export var erro_passa_a_vez: bool = true
@export var repor_mao_apos_acerto: bool = true
@export var quantidade_senhas: int = 4
## Distratoras por carta util; 1.0 = metade do baralho.
@export var proporcao_distratoras: float = 1.0
## 0 = derivado; >0 = teto de cartas do baralho (so corta distratoras).
@export var tamanho_baralho_partida: int = 0
@export var mostrar_palavra_escrita: bool = false
@export var taxa_erro_aprendiz: float = 0.3
@export var limite_turnos_partida: int = 5000
## 0 = aleatoria.
@export var semente: int = 0


func normalizar() -> void:
	tamanho_mao = clampi(tamanho_mao, 1, 10)
	silabas_por_turno = clampi(silabas_por_turno, 1, 5)
	cartas_por_troca = clampi(cartas_por_troca, 0, tamanho_mao)
	quantidade_senhas = clampi(quantidade_senhas, 1, 8)
	proporcao_distratoras = clampf(proporcao_distratoras, 0.0, 5.0)
	tamanho_baralho_partida = clampi(tamanho_baralho_partida, 0, 100)
	taxa_erro_aprendiz = clampf(taxa_erro_aprendiz, 0.0, 1.0)
	limite_turnos_partida = clampi(limite_turnos_partida, 100, 100000)
	semente = maxi(semente, 0)
