# ===========================================================================
# outputs.tf — AS "RESPOSTAS" QUE O PROJETO DEVOLVE
# ===========================================================================
# Outputs são informações que o Terraform mostra na tela no final do
# "terraform apply". Servem para você (ou outro programa) saber o que foi
# criado sem precisar entrar no console da AWS.
#
# Também dá para consultar a qualquer momento com:
#   terraform output              -> mostra todos
#   terraform output bucket_name  -> mostra só um
#   terraform output -raw bucket_name -> mostra só o valor, sem aspas
#                                        (útil para usar em outros comandos)
#
# O valor vem de "aws_s3_bucket.this.ALGUMA_COISA", ou seja, de um dado do
# bucket criado em main.tf.
# ===========================================================================


# Nome final do bucket (o mesmo que você definiu em bucket_name).
output "bucket_name" {
  description = "Nome do bucket S3 criado"
  value       = aws_s3_bucket.this.bucket
}

# ARN = "Amazon Resource Name", o "CPF" do recurso dentro da AWS.
# Formato: arn:aws:s3:::nome-do-bucket
# É usado, por exemplo, ao escrever permissões (políticas IAM).
output "bucket_arn" {
  description = "ARN do bucket S3 criado"
  value       = aws_s3_bucket.this.arn
}
