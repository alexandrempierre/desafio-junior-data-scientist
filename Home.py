__author__ = "Alexandre Pierre"
__email__ = "alexandrempierre [at] gmail [dot] com"


import functools as ft
import operator as op
from datetime import datetime, timedelta
import streamlit as st
import pandas as pd
import dados


if __name__ == "__main__":
    st.set_page_config(page_title="Home", page_icon="🏠")
    df_chamado_1746 = dados.chamado_1746()
    df_chamado_1746["data_inicio_date"] = pd.to_datetime(
        df_chamado_1746["data_inicio"]
    ).dt.normalize()
    df_bairro = dados.bairro()
    df_eventos = dados.eventos()
    #
    dfs_chamado_evento = []
    df_chamado_evento: pd.DataFrame
    df_chamado_data = df_chamado_1746
    df_chamado_data["data_inicio_date"] = pd.to_datetime(
        df_chamado_1746["data_inicio"]
    ).dt.normalize()
    df_chamado_bairro = df_chamado_data.merge(df_bairro, how="left", on="id_bairro")
    for index, row in df_eventos[["data_inicial", "data_final", "evento"]].iterrows():
        maior_que_inicio = row["data_inicial"] <= df_chamado_1746["data_inicio_date"]
        menor_que_fim = df_chamado_1746["data_inicio_date"] <= row["data_final"]
        dentro_do_intervalo = menor_que_fim & maior_que_inicio
        temp_df = df_chamado_data[dentro_do_intervalo]
        temp_df["evento"] = row["evento"]
        dfs_chamado_evento.append(temp_df)
    df_chamado_evento = pd.concat(dfs_chamado_evento)
    #
    st.title("Ocorrências ao longo do tempo")
    min_data_padrao = df_chamado_1746["data_inicio_date"].min()
    max_data_padrao = df_chamado_1746["data_inicio_date"].max()
    datas = st.date_input(
        "Intervalo",
        value=(min_data_padrao, max_data_padrao),
        min_value=min_data_padrao,
        max_value=max_data_padrao,
    )
    if isinstance(datas, tuple) and len(datas) == 2:
        min_data, max_data = datas
    elif isinstance(datas, tuple):
        min_data = datas[0]
        max_data = max_data_padrao
    else:
        min_data = datas
        max_data = max_data_padrao
    bairro = st.selectbox(
        "Bairro",
        options=["Todos"] + df_bairro["nome"].drop_duplicates().sort_values().to_list(),
    )
    if bairro == "Todos":
        bairro_correto = df_chamado_bairro["nome"] == df_chamado_bairro["nome"]
    else:
        bairro_correto = df_chamado_bairro["nome"] == bairro
    min_data_dt = datetime(min_data.year, min_data.month, min_data.day)
    max_data_dt = datetime(max_data.year, max_data.month, max_data.day) + timedelta(days=1)
    data_correta = (min_data_dt <= df_chamado_bairro["data_inicio_date"]) & (
        df_chamado_bairro["data_inicio_date"] < max_data_dt
    )
    st.line_chart(
        df_chamado_bairro[bairro_correto & data_correta]
        .groupby(["data_inicio_date"])
        .count()[["id_chamado"]]
        .rename(columns={"id_chamado": f"chamados em {bairro}"})
    )
    #
    if bairro == "Todos":
        st.title("Composição das Ocorrências de uma Data")
    else:
        st.title("Composição das Ocorrências de uma data")
    tipo_ocorrencia = st.selectbox(
        "Tipo de Ocorrência",
        options=df_chamado_1746["tipo"].drop_duplicates().sort_values().to_list(),
    )
    tipo_correto = df_chamado_bairro["tipo"] == tipo_ocorrencia
    st.bar_chart(
        df_chamado_bairro[bairro_correto & tipo_correto & data_correta]
        .groupby(["subtipo"])
        .count()[["id_chamado"]]
        .rename(columns={"id_chamado": f"chamados em {bairro}"})
    )
