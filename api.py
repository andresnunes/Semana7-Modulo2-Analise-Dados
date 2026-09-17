import os
import pandas as pd
from fastapi import FastAPI, HTTPException

# Inicializa a aplicação FastAPI
app = FastAPI(
    title="API de Vendas",
    description="Retorna o resumo de vendas processado pelo pipeline ETL"
)

# Utiliza a mesma variável de ambiente/caminho do seu ETL
LOCAL_OUTPUT_PATH = os.getenv("LOCAL_OUTPUT_PATH", "output/vendas_resumo.csv")

@app.get("/api/resumo")
def obter_resumo_vendas():
    """
    Lê o arquivo CSV de saída e retorna os dados em formato JSON.
    """
    # Verifica se o ETL já rodou e gerou o arquivo
    if not os.path.exists(LOCAL_OUTPUT_PATH):
        raise HTTPException(
            status_code=404, 
            detail="Arquivo de resumo não encontrado. Execute o ETL primeiro."
        )
    
    try:
        # Lê o CSV e converte para uma lista de dicionários (padrão JSON para APIs)
        df = pd.read_csv(LOCAL_OUTPUT_PATH)
        return df.to_dict(orient="records")
    except Exception as e:
        raise HTTPException(
            status_code=500, 
            detail=f"Erro interno ao ler os dados: {str(e)}"
        )