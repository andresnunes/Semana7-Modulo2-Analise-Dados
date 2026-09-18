# ===========================================================================
# terraform.tfvars — OS VALORES REAIS USADOS PELO TERRAFORM
# ===========================================================================
# Este é o "formulário preenchido": aqui você dá valor às variáveis que
# foram declaradas em variables.tf. O Terraform lê este arquivo
# AUTOMATICAMENTE em todo "terraform plan" e "terraform apply".
#
# Ele foi criado como cópia do terraform.tfvars.example.
# Não deve ser commitado no Git (boa prática, mesmo sem segredos aqui).
#
# ATENÇÃO: nunca coloque chaves de acesso da AWS neste arquivo. As
# credenciais ficam no AWS CLI (comando "aws configure"). Veja o README.
# ===========================================================================

# Região da AWS ("us-east-1" = EUA, "sa-east-1" = São Paulo).
aws_region = "us-east-1"

# Nome do bucket. Precisa ser único em toda a AWS.
# Se o apply der erro "BucketAlreadyExists", troque por outro nome.
bucket_name = "meu-bucket-simples-001"

# true = guarda versões antigas dos arquivos.
enable_versioning = true

# true = "terraform destroy" apaga o bucket mesmo com arquivos dentro.
force_destroy = true

# Etiquetas para organizar o bucket na AWS.
tags = {
  Project = "meu-bucket-simples"
}
