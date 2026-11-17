class_name FluxoMesa
extends RefCounted
## Decide o que a mesa faz depois de uma jogada (sem Node, sem await).

enum Etapa { FAIXA_VEZ, COFRE, NADA }


static func proxima_etapa(res: ResultadoJogada.Tipo, concluida: bool) -> Etapa:
	if res == ResultadoJogada.Tipo.INVALIDO:
		return Etapa.NADA
	if concluida:
		return Etapa.COFRE
	return Etapa.FAIXA_VEZ
