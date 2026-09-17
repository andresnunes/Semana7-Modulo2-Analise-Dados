# ETL e API de Resumo de Vendas

Este projeto consiste em um pipeline de dados simples (ETL) que processa informações de vendas e uma API construída com FastAPI para disponibilizar os dados processados em formato JSON. Toda a aplicação está configurada para rodar em um contêiner Docker.

## 🛠️ Tecnologias Utilizadas

* **Python 3.14**
* **Pandas**: Para extração, transformação e carga (ETL) dos dados.
* **FastAPI**: Para criação da API web.
* **Uvicorn**: Servidor ASGI para rodar a aplicação FastAPI.
* **Docker**: Para conteinerização da aplicação.

## 📁 Estrutura do Projeto

```text
.
├── api.py               # Código da API (FastAPI) que serve os dados processados
├── etl.py               # Script de pipeline de dados (Extração, Transformação, Carga)
├── Dockerfile           # Configuração da imagem Docker
├── requirements.txt     # Dependências do Python
└── sample_data/
    └── vendas.csv       # Arquivo de entrada com os dados brutos de vendas
```

## Como Executar com Docker (Recomendado)

A forma mais fácil de rodar o projeto é utilizando o Docker. O contêiner irá automaticamente rodar o script ETL para gerar o arquivo de saída e, em seguida, iniciar o servidor da API.

Construa a imagem Docker:

```bash
docker build -t vendas-api .
```

Rode o contêiner:

```bash
docker run -p 8000:8000 vendas-api
```

**Acesse a API:**

Swagger UI (Documentação): http://localhost:8000/docs

Endpoint de Dados: http://localhost:8000/api/resumo

## Como Executar Localmente
Se preferir rodar sem o Docker, certifique-se de ter o Python instalado em sua máquina.

Instale as dependências:

```bash
pip install -r requirements.txt
```

Execute o pipeline ETL manualmente:
Isso irá ler a pasta sample_data/ e gerar o arquivo de saída na pasta output/.

```Bash
python etl.py
```

Inicie o servidor da API:

```Bash
uvicorn api:app --reload
```

Acesse no navegador: http://127.0.0.1:8000/docs

## Endpoints Disponíveis
GET /api/resumo: Retorna a lista de categorias com o total de vendas, quantidade de pedidos e ticket médio em formato JSON.

<ElicitationsGroup message="Para enriquecer ainda mais o seu projeto:">
  <Elicitation label="Adicionar testes automatizados" query="Como posso usar a biblioteca pytest para criar testes unitários para a minha API FastAPI e meu script ETL?"/>
  <Elicitation label="Criar um arquivo .gitignore" query="O que devo incluir em um arquivo .gitignore para este projeto de ETL e API em Python?"/>
</ElicitationsGroup>