class_name FluxoMesa
extends RefCounted
## Decide o que a mesa faz depois de uma jogada (sem Node, sem await).

enum Etapa { FAIXA_VEZ, COFRE, NADA }


## `vez_passou`: a vez realmente passou para o proximo mago depois da jogada.
static func proxima_etapa(res: ResultadoJogada.Tipo, concluida: bool, vez_passou: bool) -> Etapa:
	if res == ResultadoJogada.Tipo.INVALIDO:
		return Etapa.NADA
	if concluida:
		return Etapa.COFRE
	if not vez_passou:
		return Etapa.NADA
	return Etapa.FAIXA_VEZ
