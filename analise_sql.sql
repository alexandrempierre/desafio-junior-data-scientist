/*
Localização de chamados do 1746
Utilize a tabela de Chamados do 1746 e a tabela de Bairros do Rio de Janeiro para as perguntas de 1-5.
 */

/*
Antes de começar, verifiquei que não havia nenhum pedido feito no dia 01/04/2023 
fora da partição do dia 01/04/2023 com a query a seguir:
*/

SELECT
  COUNT(*)
FROM
  `datario.adm_central_atendimento_1746.chamado`
WHERE
  CAST(data_inicio AS DATE) = "2023-04-01"
  AND data_particao <> "2023-04-01"; -- 0

/*
Outra coisa que fiz foi confirmar que há, nessa partição, outras datas de abertura
*/

SELECT
  COUNT(*)
FROM
  `datario.adm_central_atendimento_1746.chamado`
WHERE
  CAST(data_inicio AS DATE) <> "2023-04-01"
  AND data_particao = "2023-04-01"; -- 65213

/*
1. Quantos chamados foram abertos no dia 01/04/2023?
Resposta: Foram abertos 1756 chamados.
*/

SELECT
  COUNT(DISTINCT id_chamado) AS contagem_chamados
FROM
  `datario.adm_central_atendimento_1746.chamado`
WHERE
  data_particao = "2023-04-01"
  AND CAST(data_inicio AS DATE) = "2023-04-01"
LIMIT 1; -- 1756

/*
2. Qual o tipo de chamado que teve mais teve chamados abertos no dia 01/04/2023?
Resposta: Estacionamento irregular, com 366 chamados.
*/

SELECT
  id_tipo,
  ANY_VALUE(tipo) AS tipo,
  COUNT(DISTINCT id_chamado) AS qtde_chamados
FROM `datario.adm_central_atendimento_1746.chamado`
WHERE
  data_particao = "2023-04-01"
  AND CAST(data_inicio AS DATE) = "2023-04-01"
GROUP BY id_tipo
ORDER BY COUNT(DISTINCT id_chamado) DESC
LIMIT 1;

/*
3. Quais os nomes dos 3 bairros que mais tiveram chamados abertos nesse dia?
Resposta: Campo Grande (113 chamados), Tijuca (89  chamados) e Barra da Tijuca
(59 chamados).
*/

SELECT
  chamado.id_bairro,
  ANY_VALUE(bairro.nome) AS nome_bairro,
  COUNT(DISTINCT chamado.id_chamado) AS qtde_chamados
FROM
  `datario.adm_central_atendimento_1746.chamado` chamado
  INNER JOIN `datario.dados_mestres.bairro` bairro ON (
    chamado.id_bairro = bairro.id_bairro
  )
WHERE
  data_particao = "2023-04-01"
  AND CAST(data_inicio AS DATE) = "2023-04-01"
GROUP BY id_bairro
ORDER BY COUNT(DISTINCT chamado.id_chamado) DESC
LIMIT 3;

/*
4. Qual o nome da subprefeitura com mais chamados abertos nesse dia?
Resposta: Zona Norte (510 chamados).
*/

SELECT
  bairro.subprefeitura,
  COUNT(DISTINCT chamado.id_chamado) AS qtde_chamados
FROM
  `datario.adm_central_atendimento_1746.chamado` chamado
  INNER JOIN `datario.dados_mestres.bairro` bairro ON (
    chamado.id_bairro = bairro.id_bairro
  )
WHERE
  data_particao = "2023-04-01"
  AND CAST(data_inicio AS DATE) = "2023-04-01"
GROUP BY bairro.subprefeitura
ORDER BY COUNT(DISTINCT chamado.id_chamado) DESC
LIMIT 1;

/*
5. Existe algum chamado aberto nesse dia que não foi associado a um bairro ou subprefeitura na tabela de bairros? Se sim, por que isso acontece?
Resposta:
  Existem 73 entre os subtipos:
  
  1º - Verificação de ar condicionado inoperante no ônibus (49);
  2º - Solicitação de correção de falhas e de cadastro no portal e app 1746 (17);
  3º - Fiscalização de irregularidades em linha de ônibus (1);
	3º - Fiscalização de estacionamento irregular de veículo (1);
  3º - Solicitação da gravação do atendimento 1746 (1);
  3º - Fiscalização do transporte complementar (1);
  3º - Verificação do serviço BRT - Transolímpica (1);
  3º - Solicitação de orientações sobre o alvará pela internet (1);
  3º - Verificação de problemas com produtos ou serviços de fornecedores não cadastrados na Central 1746 (1).

  Todas envolvem transporte ou serviços que passam por canais eletrônicos.
*/

-- verifica se há
SELECT
  bairro.id_bairro,
  chamado.id_chamado,
  chamado.subtipo
FROM
  `datario.adm_central_atendimento_1746.chamado` chamado
  LEFT JOIN `datario.dados_mestres.bairro` bairro ON (
    chamado.id_bairro = bairro.id_bairro
  )
WHERE
  data_particao = "2023-04-01"
  AND CAST(data_inicio AS DATE) = "2023-04-01"
  AND bairro.id_bairro IS NULL;

-- ordena os subtipos com bairro vazio pelo número de ocorrências
SELECT
  chamado.subtipo,
  COUNT(DISTINCT chamado.id_chamado) AS qtde_chamados
FROM
  `datario.adm_central_atendimento_1746.chamado` chamado
  LEFT JOIN `datario.dados_mestres.bairro` bairro ON (
    chamado.id_bairro = bairro.id_bairro
  )
WHERE
  data_particao = "2023-04-01"
  AND CAST(data_inicio AS DATE) = "2023-04-01"
  AND bairro.id_bairro IS NULL
GROUP BY
  chamado.subtipo
ORDER BY
  COUNT(DISTINCT chamado.id_chamado) DESC;

/*
Chamados do 1746 em grandes eventos
Utilize a tabela de Chamados do 1746 e a tabela de Ocupação Hoteleira em Grandes Eventos no Rio para as perguntas de 6-10. Para todas as perguntas considere o subtipo de chamado "Perturbação do sossego".
*/

/* Para o intervalo de 01/01/2022 até 31/12/2023 repeti o processo do início e 
constatei que, apesar de os dados de um chamado nesse intervalo não
necessariamente estarem na partição do dia em que foi aberto, todos estão em
partições dentro do intervalo.
*/

SELECT
  COUNT(*)
FROM
  `datario.adm_central_atendimento_1746.chamado`
WHERE
  -- data_particao = "2024-08-30"
  data_inicio BETWEEN "2022-01-01" AND "2023-12-31"
  AND data_particao <> CAST(data_inicio AS DATE);


SELECT
  COUNT(*)
FROM
  `datario.adm_central_atendimento_1746.chamado`
WHERE
  data_inicio BETWEEN "2022-01-01" AND "2023-12-31"
  AND data_particao NOT BETWEEN "2022-01-01" AND "2023-12-31"; -- 0

/*
6. Quantos chamados com o subtipo "Perturbação do sossego" foram abertos desde 01/01/2022 até 31/12/2023 (incluindo extremidades)?
Resposta: Foram abertos 42830 chamados.
*/

SELECT
  COUNT(id_chamado)
FROM
  `datario.adm_central_atendimento_1746.chamado`
WHERE
  data_particao BETWEEN "2022-01-01" AND "2023-12-31"
  AND data_inicio BETWEEN "2022-01-01" AND "2023-12-31"
  AND subtipo = "Perturbação do sossego";

/*
7. Selecione os chamados com esse subtipo que foram abertos durante os eventos contidos na tabela de eventos (Reveillon, Carnaval e Rock in Rio).
Resposta:
*/

SELECT
  eventos.evento,
  chamado.*
FROM
  `datario.adm_central_atendimento_1746.chamado` chamado
  INNER JOIN `datario.turismo_fluxo_visitantes.rede_hoteleira_ocupacao_eventos` eventos ON (
    chamado.data_inicio BETWEEN eventos.data_inicial AND eventos.data_final
  )
WHERE
  data_particao BETWEEN "2022-01-01" AND "2023-12-31"
  AND subtipo = "Perturbação do sossego";


/*
8. Quantos chamados desse subtipo foram abertos em cada evento?
Resposta: 518 no Rock in Rio, 197 no Carnaval e 81 no Reveillon.
*/

SELECT
  eventos.evento,
  COUNT(chamado.id_chamado),
FROM
  `datario.adm_central_atendimento_1746.chamado` chamado
  INNER JOIN `datario.turismo_fluxo_visitantes.rede_hoteleira_ocupacao_eventos` eventos ON (
    chamado.data_inicio BETWEEN eventos.data_inicial AND eventos.data_final
  )
WHERE
  data_particao BETWEEN "2022-01-01" AND "2023-12-31"
  AND subtipo = "Perturbação do sossego"
GROUP BY
  eventos.evento;

/*
9. Qual evento teve a maior média diária de chamados abertos desse subtipo?
Resposta: Rock in Rio com 103,6 chamados por dia.
*/

WITH evento_duracao AS (
  SELECT evento, SUM(DATE_DIFF(data_final, data_inicial, DAY)) AS duracao FROM `datario.turismo_fluxo_visitantes.rede_hoteleira_ocupacao_eventos` GROUP BY evento
)
SELECT
  eventos.evento,
  COUNT(chamado.id_chamado) / ANY_VALUE(evento_duracao.duracao) AS chamados_por_dia,
FROM
  `datario.adm_central_atendimento_1746.chamado` chamado
  INNER JOIN `datario.turismo_fluxo_visitantes.rede_hoteleira_ocupacao_eventos` eventos ON (
    chamado.data_inicio BETWEEN eventos.data_inicial AND eventos.data_final
  )
  INNER JOIN evento_duracao ON (
    eventos.evento = evento_duracao.evento
  )
WHERE
  data_particao BETWEEN "2022-01-01" AND "2023-12-31"
  AND subtipo = "Perturbação do sossego"
GROUP BY
  eventos.evento;

/*
10. Compare as médias diárias de chamados abertos desse subtipo durante os eventos específicos (Reveillon, Carnaval e Rock in Rio) e a média diária de chamados abertos desse subtipo considerando todo o período de 01/01/2022 até 31/12/2023.
Resposta: A média de chamados do intervalo (aprox 58,75 chamados/dia) é menor
que as de Rock in Rio (103,6 chamados/dia) e Carnaval (aprox 65,67 chamados/dia)
e menor que Reveillon (40.5 chamados/dia).
*/

WITH evento_duracao AS (
  SELECT evento, SUM(DATE_DIFF(data_final, data_inicial, DAY)) AS duracao FROM `datario.turismo_fluxo_visitantes.rede_hoteleira_ocupacao_eventos` GROUP BY evento
),
media_evento AS (
  SELECT
    eventos.evento,
    COUNT(chamado.id_chamado) / ANY_VALUE(evento_duracao.duracao) AS chamados_por_dia,
  FROM
    `datario.adm_central_atendimento_1746.chamado` chamado
    INNER JOIN `datario.turismo_fluxo_visitantes.rede_hoteleira_ocupacao_eventos` eventos ON (
      chamado.data_inicio BETWEEN eventos.data_inicial AND eventos.data_final
    )
    INNER JOIN evento_duracao ON (
      eventos.evento = evento_duracao.evento
    )
  WHERE
    data_particao BETWEEN "2022-01-01" AND "2023-12-31"
    AND subtipo = "Perturbação do sossego"
  GROUP BY
    eventos.evento
),
media_intervalo AS (
  SELECT
    "Intervalo de 01/01/2022 a 31/12/2023" AS evento,
    COUNT(id_chamado) / DATE_DIFF("2023-12-31", "2022-01-01", DAY) AS chamados_por_dia
  FROM 
    `datario.adm_central_atendimento_1746.chamado`
  WHERE
    data_particao BETWEEN "2022-01-01" AND "2023-12-31"
    AND subtipo = "Perturbação do sossego"
)
SELECT evento, chamados_por_dia FROM media_evento
UNION ALL
SELECT evento, chamados_por_dia FROM media_intervalo
ORDER BY chamados_por_dia DESC;



