import logging
import os
import sys
from io import StringIO
import pandas as pd

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(message)s",
)
logger = logging.getLogger("etl")

LOCAL_INPUT_PATH = os.getenv("LOCAL_INPUT_PATH", "sample_data/vendas.csv")
LOCAL_OUTPUT_PATH = os.getenv("LOCAL_OUTPUT_PATH", "output/vendas_resumo.csv")


def extract() -> pd.DataFrame:
    logger.info("Extraindo dados localmente de %s", LOCAL_INPUT_PATH)
    return pd.read_csv(LOCAL_INPUT_PATH)


def transform(df: pd.DataFrame) -> pd.DataFrame:
    logger.info("Transformando %d linhas", len(df))

    df = df.dropna(subset=["categoria"]).copy()
    df["valor"] = pd.to_numeric(df["valor"], errors="coerce")
    df = df.dropna(subset=["valor"])

    resumo = (
        df.groupby("categoria", as_index=False)
        .agg(total_vendas=("valor", "sum"), qtd_pedidos=("valor", "count"))
        .sort_values("total_vendas", ascending=False)
    )
    resumo["ticket_medio"] = (resumo["total_vendas"] / resumo["qtd_pedidos"]).round(2)
    resumo["total_vendas"] = resumo["total_vendas"].round(2)

    logger.info("Transformação concluída: %d categorias", len(resumo))
    return resumo

def load(df: pd.DataFrame) -> None:
    os.makedirs(os.path.dirname(LOCAL_OUTPUT_PATH) or ".", exist_ok=True)
    df.to_csv(LOCAL_OUTPUT_PATH, index=False)
    logger.info("Resultado salvo localmente em %s", LOCAL_OUTPUT_PATH)


if __name__ == "__main__":
    try:
        raw_df = extract()
        result_df = transform(raw_df)
        load(result_df)
        logger.info("=== Pipeline concluído com sucesso ===")
    except Exception:
        logger.exception("Falha na execução do pipeline")
        sys.exit(1)
