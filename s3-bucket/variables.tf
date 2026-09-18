# ===========================================================================
# variables.tf — AS "PERGUNTAS" QUE O PROJETO FAZ
# ===========================================================================
# Este arquivo DECLARA as variáveis: quais informações o projeto precisa
# receber para funcionar. Ele não define os valores reais — isso é feito
# no terraform.tfvars.
#
# Pense assim: variables.tf é o formulário em branco; terraform.tfvars é o
# formulário preenchido.
#
# Cada bloco "variable" tem:
#   - description: explicação do que a variável significa.
#   - type:        tipo do valor (string = texto, bool = true/false,
#                  map(string) = lista de pares "chave = texto").
#   - default:     valor usado se você não informar nada. Variáveis SEM
#                  default são obrigatórias (o Terraform pergunta se faltar).
#
# Para usar uma variável em outro arquivo, escreva: var.NOME
# ===========================================================================


# Em qual região (data center) da AWS o bucket será criado.
# "us-east-1" = Norte da Virgínia (EUA), a região mais comum e barata.
# Para São Paulo, use "sa-east-1".
variable "aws_region" {
  description = "Região da AWS onde o bucket será criado"
  type        = string
  default     = "us-east-1"
}

# Nome do bucket. OBRIGATÓRIA (não tem default).
# Regras da AWS: só letras minúsculas, números, pontos e hífens; entre 3 e
# 63 caracteres; e único no mundo todo.
variable "bucket_name" {
  description = "Nome do bucket S3 (precisa ser único globalmente em toda a AWS)"
  type        = string
}

# Liga (true) ou pausa (false) o versionamento. Usada em main.tf, bloco 2.
variable "enable_versioning" {
  description = "Habilita versionamento de objetos no bucket"
  type        = bool
  default     = true
}

# Permite (true) apagar o bucket mesmo com arquivos dentro.
# Útil em aula para não precisar esvaziar o bucket antes do destroy.
# Em um ambiente real, deixe "false" para evitar perder dados por engano.
variable "force_destroy" {
  description = "Permite 'terraform destroy' apagar o bucket mesmo com objetos dentro (conveniência de laboratório — desative em produção)"
  type        = bool
  default     = true
}

# Etiquetas do bucket. Ex.: { Project = "meu-projeto", Owner = "andre" }.
# O default "{}" significa "nenhuma tag".
variable "tags" {
  description = "Tags aplicadas ao bucket"
  type        = map(string)
  default     = {}
}
