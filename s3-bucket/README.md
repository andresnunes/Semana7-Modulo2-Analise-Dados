# Terraform — S3 simples

Módulo Terraform independente (state próprio) que cria **apenas um bucket
S3** — privado, com versionamento e criptografia habilitados por padrão.
Não depende de nenhum outro módulo deste repositório.

> **Em uma frase:** em vez de clicar no console da AWS para criar um bucket,
> você descreve o bucket em arquivos de texto (`.tf`) e o Terraform cria
> tudo sozinho, sempre do mesmo jeito.

## O que é criado

- 1 bucket S3 (`aws_s3_bucket`) — o "pendrive na nuvem" onde ficam os arquivos
- Versionamento (`aws_s3_bucket_versioning`) — guarda versões antigas dos arquivos
- Bloqueio de acesso público (`aws_s3_bucket_public_access_block`) — ninguém de fora acessa
- Criptografia padrão AES256 (`aws_s3_bucket_server_side_encryption_configuration`) — arquivos gravados criptografados

## Como tudo se conecta

```text
terraform.tfvars ──(valores)──▶ variables.tf ──(var.xxx)──▶ main.tf ──▶ AWS (bucket criado)
                                                               ▲
versions.tf ── provider AWS + região ──────────────────────────┘
               (credenciais vêm do AWS CLI)

Depois do "terraform apply":
  terraform.tfstate  ◀── Terraform anota o que criou (a "memória" dele)
  outputs.tf         ──▶ mostra na tela o nome e o ARN do bucket
```

1. Você escreve os **valores** em `terraform.tfvars` (ex.: nome do bucket).
2. `variables.tf` diz **quais** valores existem e de que tipo são.
3. `main.tf` usa esses valores (`var.bucket_name`, etc.) para descrever o bucket.
4. `versions.tf` diz **como** falar com a AWS (provider e região). As
   credenciais (login) vêm do **AWS CLI**, configurado mais abaixo.
5. Ao rodar `terraform apply`, o Terraform cria o bucket, anota tudo em
   `terraform.tfstate` e mostra os `outputs`.

## Arquivos desta pasta

| Arquivo | Para que serve | Você edita? |
|---|---|---|
| [versions.tf](versions.tf) | Versão do Terraform, provider AWS e região | Raramente |
| [variables.tf](variables.tf) | Declara as variáveis (o "formulário em branco") | Só para criar variável nova |
| [terraform.tfvars.example](terraform.tfvars.example) | Modelo de valores para copiar | Não (é só modelo) |
| [terraform.tfvars](terraform.tfvars) | Valores reais (o "formulário preenchido") | **Sim** |
| [main.tf](main.tf) | Os recursos criados na AWS | Sim, para mudar a infraestrutura |
| [outputs.tf](outputs.tf) | O que aparece na tela no final | Raramente |
| `terraform.tfstate` | Memória do Terraform (gerado automaticamente) | **Nunca à mão** |
| `.terraform/` e `.terraform.lock.hcl` | Criados pelo `terraform init` | Não |

Todos os arquivos `.tf` e `.tfvars` têm comentários linha a linha. Abaixo,
um resumo de cada um.

### `versions.tf`

- **O que é:** a configuração do próprio Terraform e da conexão com a AWS.
- **Como é feito:** um bloco `terraform { }` com a versão mínima
  (`>= 1.5`) e o provider `hashicorp/aws` na versão `~> 5.0` (qualquer 5.x);
  e um bloco `provider "aws" { }` com a região.
- **O que está fazendo aqui:** manda o `terraform init` baixar o plugin da
  AWS e define a região a partir de `var.aws_region`. Não tem nenhuma senha
  no arquivo: o login vem do AWS CLI. Também tem um exemplo comentado de
  *backend S3* (guardar o state na nuvem para trabalho em equipe).

### `variables.tf`

- **O que é:** a lista de informações que o projeto precisa receber.
- **Como é feito:** um bloco `variable "nome" { }` para cada informação,
  com `description` (explicação), `type` (tipo) e, opcionalmente, `default`
  (valor padrão). Sem `default`, a variável é obrigatória.
- **O que está fazendo aqui:** declara 5 variáveis — `aws_region`,
  `bucket_name` (obrigatória), `enable_versioning`, `force_destroy` e `tags`.

### `terraform.tfvars.example` e `terraform.tfvars`

- **O que é:** o `.example` é um modelo; o `terraform.tfvars` é o arquivo
  de verdade, com os seus valores.
- **Como é feito:** linhas no formato `nome = valor`, uma para cada
  variável de `variables.tf`.
- **O que está fazendo aqui:** define região `us-east-1`, bucket
  `meu-bucket-simples-001`, versionamento ligado, `force_destroy` ligado e a
  tag `Project`. O Terraform lê o `terraform.tfvars` sozinho a cada
  `plan`/`apply`; o `.example` é ignorado por ele.

### `main.tf`

- **O que é:** o coração do projeto — o que será criado na AWS.
- **Como é feito:** blocos `resource "tipo" "nome" { }`. Os três últimos
  recursos apontam para o primeiro com `aws_s3_bucket.this.id`, e é assim
  que o Terraform descobre que precisa criar o bucket antes das configurações.
- **O que está fazendo aqui:** cria o bucket e aplica nele versionamento,
  bloqueio total de acesso público e criptografia AES256.

### `outputs.tf`

- **O que é:** as "respostas" que o Terraform mostra no final.
- **Como é feito:** blocos `output "nome" { value = ... }` lendo dados do
  bucket criado.
- **O que está fazendo aqui:** mostra o **nome** e o **ARN** (identificador
  único na AWS, formato `arn:aws:s3:::nome-do-bucket`) do bucket.

### `terraform.tfstate`

- **O que é:** a "memória" do Terraform. É um arquivo JSON **gerado
  automaticamente** depois do primeiro `terraform apply`.
- **Como é feito:** o próprio Terraform escreve nele tudo o que criou (IDs,
  ARN, região, configurações). A cada `plan`/`apply`, ele compara o código
  `.tf` com esse arquivo e com a AWS para saber o que criar, mudar ou apagar.
- **O que está fazendo aqui:** registra que o bucket `meu-bucket-simples-001`
  e as suas 3 configurações existem em `us-east-1`.
- **Cuidados:** não edite à mão e não apague enquanto o bucket existir —
  sem ele, o Terraform "esquece" o bucket e não consegue mais gerenciá-lo
  nem destruí-lo. Pode aparecer também um `terraform.tfstate.backup` (a
  versão anterior do state).

### `.terraform/` e `.terraform.lock.hcl`

Criados pelo `terraform init`. A pasta `.terraform/` guarda o plugin da AWS
baixado (pode ser apagada; o `init` baixa de novo). O `.terraform.lock.hcl`
"trava" a versão exata do provider para todo mundo usar a mesma.

## Pré-requisitos

1. **Terraform** ≥ 1.5
   ```powershell
   winget install HashiCorp.Terraform
   ```
2. **AWS CLI** versão 2, instalado e configurado com credenciais válidas
   (passo a passo na próxima seção).
3. Uma conta AWS com permissão para criar/gerenciar buckets S3.

Depois de instalar, **feche e abra de novo** o terminal (ou o VS Code) e
confira:

```powershell
terraform -version
aws --version
```

## Instalar e configurar o AWS CLI

O **AWS CLI** é o programa de linha de comando da AWS. Aqui ele tem dois
papéis:

- guardar o seu **login** (chaves de acesso) no computador — o Terraform
  usa esse mesmo login automaticamente;
- permitir conferir o bucket pelo terminal (`aws s3 ls`, `aws s3 cp`...).

### 1. Instalar

**Windows (recomendado — winget):**

```powershell
winget install -e --id Amazon.AWSCLI
```

**Windows (alternativa — instalador MSI):**

```powershell
msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi
```

Ou baixe o instalador em <https://awscli.amazonaws.com/AWSCLIV2.msi> e
siga o "Avançar, Avançar, Concluir".

<details>
<summary>Linux e macOS</summary>

**Linux (x86_64):**

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

**macOS:**

```bash
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /
```

</details>

### 2. Conferir a instalação

Feche e abra o terminal (para ele enxergar o programa novo) e rode:

```powershell
aws --version
```

Deve aparecer algo como `aws-cli/2.x.x Python/3.x.x Windows/11 exe/AMD64`.

### 3. Criar uma chave de acesso na AWS

O AWS CLI precisa de uma **Access Key ID** (parecida com um usuário) e de
uma **Secret Access Key** (parecida com uma senha). Elas são criadas para
um **usuário IAM**:

1. Entre no [Console da AWS](https://console.aws.amazon.com/) e abra o
   serviço **IAM**.
2. Vá em **Users (Usuários) → Create user (Criar usuário)**.
3. Dê um nome, por exemplo `terraform-aluno`. Não precisa marcar acesso
   ao console.
4. Em permissões, escolha **Attach policies directly (Anexar políticas
   diretamente)** e marque **`AmazonS3FullAccess`** (suficiente para este
   laboratório). Clique em **Create user**.
5. Abra o usuário criado → aba **Security credentials (Credenciais de
   segurança)** → **Create access key (Criar chave de acesso)**.
6. Em "caso de uso", escolha **Command Line Interface (CLI)**, confirme o
   aviso e avance até **Create access key**.
7. Copie a **Access key ID** e a **Secret access key** (ou clique em
   **Download .csv**). A secret aparece **uma única vez** — se perder, é
   preciso criar outra chave.

> ⚠️ **Segurança:**
> - Não crie chaves para o usuário *root* (o e-mail principal da conta).
> - Nunca coloque as chaves em arquivos `.tf`/`.tfvars` nem suba para o Git.
> - Se uma chave vazar, desative-a no IAM na hora.

### 4. Configurar o AWS CLI (`aws configure`)

```powershell
aws configure
```

O comando faz 4 perguntas:

```text
AWS Access Key ID [None]: AKIAXXXXXXXXXXXXXXXX      ← cole a Access key ID
AWS Secret Access Key [None]: xxxxxxxxxxxxxxxxxxxx  ← cole a Secret access key
Default region name [None]: us-east-1               ← região padrão
Default output format [None]: json                  ← formato das respostas
```

Pronto: as respostas ficam salvas em dois arquivos na sua pasta de usuário:

| Arquivo | Conteúdo |
|---|---|
| `C:\Users\<seu-usuario>\.aws\credentials` | As chaves (`aws_access_key_id`, `aws_secret_access_key`) |
| `C:\Users\<seu-usuario>\.aws\config` | Região e formato de saída |

(No Linux/macOS: `~/.aws/credentials` e `~/.aws/config`.)

É desses arquivos que o Terraform lê o login — por isso nenhum `.tf`
precisa ter senha.

### 5. Testar o login

```powershell
aws sts get-caller-identity
```

Se estiver tudo certo, a AWS responde **quem é você**:

```json
{
    "UserId": "AIDAXXXXXXXXXXXXXXXXX",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/terraform-aluno"
}
```

### Alternativa: AWS Academy / Learner Lab (credenciais temporárias)

Se você usa uma conta do **AWS Academy**, não dá para criar usuário IAM. Em
vez disso:

1. Inicie o laboratório (**Start Lab**) e espere a bolinha ficar verde.
2. Clique em **AWS Details → AWS CLI: Show**.
3. Copie o bloco inteiro (`[default]`, `aws_access_key_id`,
   `aws_secret_access_key` e `aws_session_token`).
4. Cole no arquivo de credenciais, substituindo o conteúdo antigo:
   ```powershell
   New-Item -ItemType Directory -Force "$env:USERPROFILE\.aws"
   notepad "$env:USERPROFILE\.aws\credentials"
   ```
5. Teste com `aws sts get-caller-identity`.

Essas credenciais **expiram** quando a sessão do laboratório termina —
repita os passos a cada nova sessão.

### Opcional: mais de uma conta (perfis)

```powershell
aws configure --profile senai          # cria um perfil chamado "senai"
aws sts get-caller-identity --profile senai

# Para o Terraform usar esse perfil (vale só para este terminal):
$env:AWS_PROFILE = "senai"
```

### Problemas comuns

| Mensagem | O que fazer |
|---|---|
| `aws : O termo 'aws' não é reconhecido...` | Feche e abra o terminal/VS Code. Se continuar, reinstale o AWS CLI. |
| `Unable to locate credentials` | O `aws configure` ainda não foi feito (ou o perfil está errado). |
| `InvalidClientTokenId` / `SignatureDoesNotMatch` | Chave copiada errada. Rode `aws configure` de novo. |
| `ExpiredToken` | Credencial temporária (AWS Academy) expirou. Copie as novas. |
| `AccessDenied` ao criar o bucket | O usuário IAM não tem permissão no S3 (veja o passo 3). |
| `BucketAlreadyExists` | Alguém no mundo já usa esse nome. Troque o `bucket_name`. |

## Passo a passo (Terraform)

### 1. Conferir as credenciais da AWS

O provider `aws` do Terraform usa a mesma cadeia de credenciais do AWS
CLI — não é preciso escrever chaves dentro dos arquivos `.tf`.

```powershell
aws sts get-caller-identity
```

Se der erro, volte para [Instalar e configurar o AWS CLI](#instalar-e-configurar-o-aws-cli).

### 2. Configurar as variáveis

A partir da raiz do repositório:

```powershell
cd s3-bucket
copy terraform.tfvars.example terraform.tfvars
```

Edite `terraform.tfvars` e ajuste pelo menos `bucket_name` (o nome de um
bucket S3 precisa ser **único em toda a AWS**, não só na sua conta).

### 3. Inicializar o Terraform

```powershell
terraform init
```

Baixa o provider `aws` e prepara o diretório (cria `.terraform/` e
`.terraform.lock.hcl`). Só precisa rodar de novo se mudar o `versions.tf`.

### 4. Revisar o plano

```powershell
terraform plan
```

Mostra o que será criado, sem alterar nada ainda. Linhas com `+` serão
criadas, `~` alteradas e `-` apagadas.

### 5. Aplicar

```powershell
terraform apply
```

Confirme com `yes` quando solicitado. Ao final, o Terraform mostra o
nome e o ARN do bucket criado e grava o `terraform.tfstate`.

### 6. Conferir

```powershell
terraform output bucket_name
aws s3 ls s3://$(terraform output -raw bucket_name)
```

Para testar enviando um arquivo:

```powershell
"ola, S3" | Out-File teste.txt
aws s3 cp teste.txt s3://$(terraform output -raw bucket_name)/
aws s3 ls s3://$(terraform output -raw bucket_name)
```

### 7. Destruir (evitar cobrança)

```powershell
terraform destroy
```

`force_destroy = true` (padrão em `terraform.tfvars.example`) permite
apagar o bucket mesmo que existam objetos dentro — pensado para uso de
estudo/laboratório. **Desative essa opção** (em `terraform.tfvars`,
`force_destroy = false`) se este bucket guardar dados reais, para evitar
perda acidental.

## O que não enviar para o Git

`terraform.tfvars` (valores pessoais), `terraform.tfstate` (pode conter
dados sensíveis em outros projetos) e `.terraform/` (arquivos baixados,
pesados) não devem ser commitados. Um `.gitignore` típico:

```gitignore
.terraform/
*.tfstate
*.tfstate.*
terraform.tfvars
```

## State remoto (opcional)

Por padrão o state fica local (`terraform.tfstate` nesta pasta). Para
trabalhar em equipe, veja o bloco `backend "s3"` comentado em
[versions.tf](versions.tf).
