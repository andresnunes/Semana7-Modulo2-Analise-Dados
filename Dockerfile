# Imagem base
FROM python:3.14

# Local interno da Imagem Customizada para o aplicativo
WORKDIR /usr/src/app

# Copia os arquivos externos para dentro da Imagem Customizada
# Primeiro vem a origem e em seguida o destino
COPY requirements.txt .

# Instala as dependências (pandas, fastapi, uvicorn)
# Executa um comando como um terminal linux, acontece dentro do container
RUN pip install --no-cache-dir -r requirements.txt

# Copia os scripts python para dentro da imagem
COPY etl.py .
COPY api.py .

# Copia a pasta de dados base
COPY sample_data ./sample_data

# Informa ao Docker que o contêiner vai escutar na porta 8000
EXPOSE 8000

# Removemos o ENTRYPOINT antigo e usamos o CMD para encadear os comandos.
# O 'sh -c' permite rodar o ETL primeiro (gerando o CSV) e, se der sucesso (&&),
# sobe o servidor da API liberando o acesso externo (--host 0.0.0.0).
CMD ["sh", "-c", "python etl.py && uvicorn api:app --host 0.0.0.0 --port 8000"]