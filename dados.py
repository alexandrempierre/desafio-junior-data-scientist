__all__ = ["chamado_1746", "bairro", "eventos"]
__author__ = "Alexandre Pierre"
__email__ = "alexandrempierre [at] gmail [dot] com"


import pandas as pd
import basedosdados as bd

from dotenv import get_key
from pathlib import Path


BILLING_PROJECT_ID = get_key(".env", "BILLING_PROJECT_ID")


def chamado_1746() -> pd.DataFrame:
    query = """
        SELECT
            id_chamado
            ,data_inicio
            ,id_bairro
            ,id_tipo
            ,tipo
            ,id_subtipo
            ,subtipo
        FROM
            `datario.adm_central_atendimento_1746.chamado`
        WHERE
            data_particao BETWEEN '2022-01-01' AND '2023-12-31'
            AND EXTRACT(DATE FROM data_inicio) BETWEEN '2022-01-01' AND '2023-12-31'
    """
    parquet_chamado_path = Path("chamado_1746.parquet")
    if parquet_chamado_path.exists():
        df_chamado_1746 = pd.read_parquet(parquet_chamado_path)
    else:
        df_chamado_1746 = bd.read_sql(
            query,
            billing_project_id=BILLING_PROJECT_ID,
        )
        df_chamado_1746.to_parquet(parquet_chamado_path)
    return df_chamado_1746


def bairro() -> pd.DataFrame:
    parquet_bairro_path = Path("bairro.parquet")
    if parquet_bairro_path.exists():
        df_bairro = pd.read_parquet(parquet_bairro_path)
    else:
        df_bairro = bd.read_table(
            dataset_id="dados_mestres",
            table_id="bairro",
            billing_project_id=BILLING_PROJECT_ID,
            query_project_id="datario",
        )
        df_bairro.to_parquet(parquet_bairro_path)
    return df_bairro


def eventos() -> pd.DataFrame:
    parquet_eventos_path = Path("eventos.parquet")
    if parquet_eventos_path.exists():
        df_eventos = pd.read_parquet(parquet_eventos_path)
    else:
        df_eventos = bd.read_table(
            dataset_id="turismo_fluxo_visitantes",
            table_id="rede_hoteleira_ocupacao_eventos",
            billing_project_id=BILLING_PROJECT_ID,
            query_project_id="datario",
        )
        df_eventos["data_inicial"] = pd.to_datetime(df_eventos["data_inicial"])
        df_eventos["data_final"] = pd.to_datetime(df_eventos["data_final"])
        df_eventos.to_parquet(parquet_eventos_path)
    return df_eventos
