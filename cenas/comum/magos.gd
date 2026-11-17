class_name Magos
extends RefCounted
## Cor, nome e simbolo fixos de cada mago. O id do mago e o indice dos arrays.

enum Simbolo { SOL, LUA, FOLHA, ESTRELA }

const COR: Array[Color] = [Color("#E03C3C"), Color("#2F7BFF"), Color("#2EAD5E"), Color("#F2C200")]
const COR_TEXTO: Array[Color] = [Color.WHITE, Color.WHITE, Color.WHITE, Color("#14213D")]
const NOME: Array[String] = ["Vermelho", "Azul", "Verde", "Amarelo"]


## Mapeia o indice do nucleo (0..n-1) para o id do n-esimo mago ativo.
static func id_do_indice(ativos: Array[int], indice: int) -> int:
	return ativos[indice]
