# ===========================================================================
# main.tf — O "CORAÇÃO" DO PROJETO
# ===========================================================================
# Aqui ficam os RECURSOS, ou seja, as coisas que o Terraform vai criar de
# verdade dentro da sua conta AWS. Neste projeto, é um bucket S3 (um
# "pendrive na nuvem" onde você guarda arquivos) e três configurações dele.
#
# Como ler um bloco "resource":
#
#   resource "TIPO_DO_RECURSO" "NOME_INTERNO" {
#     configuracao = valor
#   }
#
#   - TIPO_DO_RECURSO: o que será criado na AWS (ex.: aws_s3_bucket).
#   - NOME_INTERNO: um apelido usado só dentro do Terraform para referenciar
#     esse recurso em outros lugares (aqui usamos "this" = "este").
#   - var.algo: lê um valor definido em variables.tf / terraform.tfvars.
#
# O Terraform descobre sozinho a ORDEM de criação: como os blocos 2, 3 e 4
# usam "aws_s3_bucket.this.id", ele sabe que precisa criar o bucket primeiro.
# ===========================================================================


# ---------------------------------------------------------------------------
# 1) O BUCKET — simples, privado por padrão
# ---------------------------------------------------------------------------
# Cria o bucket em si. É o único recurso "obrigatório"; os outros três
# apenas ajustam configurações deste bucket.
resource "aws_s3_bucket" "this" {
  # Nome do bucket. Vem da variável "bucket_name" (definida em
  # terraform.tfvars). Precisa ser único no mundo inteiro, não só na sua conta.
  bucket = var.bucket_name

  # Se "true", o "terraform destroy" apaga o bucket MESMO com arquivos
  # dentro. Se "false", a AWS se recusa a apagar um bucket que não está vazio.
  force_destroy = var.force_destroy

  # Tags são etiquetas (chave = valor) que ajudam a organizar e a
  # identificar custos na AWS. Ex.: { Project = "meu-bucket-simples" }.
  tags = var.tags
}


# ---------------------------------------------------------------------------
# 2) VERSIONAMENTO — guarda versões antigas dos arquivos
# ---------------------------------------------------------------------------
# Com o versionamento ligado, se você sobrescrever ou apagar um arquivo,
# a versão anterior continua guardada e pode ser recuperada.
# (Atenção: versões antigas também ocupam espaço e podem gerar custo.)
resource "aws_s3_bucket_versioning" "this" {
  # Diz a qual bucket esta configuração se aplica: o bucket criado no bloco 1.
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    # Operador ternário: "condição ? se_verdadeiro : se_falso".
    # Se enable_versioning = true  -> "Enabled"   (ligado)
    # Se enable_versioning = false -> "Suspended" (pausado)
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}


# ---------------------------------------------------------------------------
# 3) BLOQUEIO DE ACESSO PÚBLICO — ninguém de fora acessa o bucket
# ---------------------------------------------------------------------------
# Garante que o bucket NUNCA fique público na internet, mesmo que alguém
# tente liberar por engano. São quatro "travas" de segurança, todas ligadas:
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  # Recusa novas permissões públicas (ACLs) em arquivos ou no bucket.
  block_public_acls = true

  # Recusa políticas (regras de acesso) que deixariam o bucket público.
  block_public_policy = true

  # Ignora qualquer permissão pública que já exista.
  ignore_public_acls = true

  # Mesmo que exista uma política pública, só a própria conta AWS acessa.
  restrict_public_buckets = true
}


# ---------------------------------------------------------------------------
# 4) CRIPTOGRAFIA — arquivos guardados "embaralhados" no disco da AWS
# ---------------------------------------------------------------------------
# Todo arquivo enviado ao bucket é criptografado automaticamente pela AWS
# antes de ser gravado. Para você, nada muda: ao baixar, o arquivo volta
# normal. É uma proteção caso alguém tenha acesso físico aos discos.
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      # AES256 = criptografia gerenciada pela própria AWS (chamada SSE-S3).
      # Não tem custo extra e não exige configurar chaves.
      sse_algorithm = "AES256"
    }
  }
}
