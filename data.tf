# data.tf (Repositório de Banco de Dados)

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    # Certifique-se que o bucket e a key batem com onde o Repo 2 salvou o estado
    bucket = "tech-challenge-fiap-s3-bucket" 
    key    = "infra-k8s/terraform.tfstate" 
    region = "us-east-1"
  }
}

# Se você não usa o "principal_user" dentro do database.tf (para tags, por exemplo),
# você também pode remover este bloco abaixo. Se usa, mantenha.
data "aws_iam_user" "principal_user" {
  user_name = "terraform-dev"
}

# --- REMOVIDO: data "aws_eks_cluster" ---
# O banco não precisa saber o nome do cluster, e esse recurso não existe aqui.

# --- REMOVIDO: data "aws_eks_cluster_auth" ---
# O banco não precisa se autenticar no Kubernetes.