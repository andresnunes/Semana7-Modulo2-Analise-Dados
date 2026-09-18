# ===========================================================================
# versions.tf — CONFIGURAÇÃO DO PRÓPRIO TERRAFORM E DA CONEXÃO COM A AWS
# ===========================================================================
# Este arquivo não cria nada na AWS. Ele diz:
#   1. Qual versão do Terraform é aceita.
#   2. Qual "provider" (plugin) usar para conversar com a AWS, e a versão.
#   3. Onde guardar o arquivo de state (terraform.tfstate).
#   4. Em qual região da AWS trabalhar.
#
# O "terraform init" lê este arquivo e baixa o provider para a pasta
# .terraform/ (criada automaticamente).
# ===========================================================================

terraform {
  # Exige Terraform 1.5 ou mais novo. Com versão mais antiga, dá erro.
  required_version = ">= 1.5"

  required_providers {
    # Provider = plugin que traduz o código Terraform em chamadas à API da
    # AWS. Sem ele, o Terraform não sabe o que é um "aws_s3_bucket".
    aws = {
      # De onde baixar: registry.terraform.io/hashicorp/aws
      source = "hashicorp/aws"

      # "~> 5.0" = qualquer versão 5.x (5.1, 5.80...), mas NÃO a 6.0.
      # Evita que uma atualização grande quebre o código de surpresa.
      version = "~> 5.0"
    }
  }

  # Por padrão o state fica local (terraform.tfstate neste diretório) —
  # ótimo para estudo/uso individual. Para trabalhar em equipe, descomente
  # e ajuste o backend abaixo (o bucket e a tabela DynamoDB precisam já
  # existir antes do "terraform init" — normalmente são criados uma única
  # vez, à mão ou em um Terraform separado "de bootstrap").
  #
  # Em palavras simples: o state é a "memória" do Terraform (o que ele já
  # criou). Guardá-lo num bucket S3 permite que várias pessoas usem a mesma
  # memória, e a tabela DynamoDB funciona como um "cadeado" para que duas
  # pessoas não rodem "terraform apply" ao mesmo tempo.
  #
  # backend "s3" {
  #   bucket         = "minha-empresa-terraform-state"
  #   key            = "etl-docker-aws/s3-bucket/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "terraform-locks"
  #   encrypt        = true
  # }
}

# Configura o provider AWS: em qual região os recursos serão criados.
# Repare que NÃO há usuário/senha aqui: o Terraform pega as credenciais
# automaticamente do AWS CLI (arquivo ~/.aws/credentials, criado pelo
# comando "aws configure") ou de variáveis de ambiente. Veja o README.
provider "aws" {
  region = var.aws_region
}
