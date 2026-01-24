resource "aws_security_group" "db_sg" {
  name        = "db-security-group"
  description = "Permite acesso ao RDS"
  
  # AQUI TAMBÉM: O SG precisa saber em qual VPC ele vai ser criado
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 2. Criar a regra de liberação no Security Group do Banco de Dados
resource "aws_security_group_rule" "allow_eks_to_rds" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  
  # AQUI É IMPORTANTE: Substitua pelo NOME do recurso do SG do seu banco no Terraform
  # Se você não tiver o recurso SG isolado, pode ser security_group_id = data.aws_db_instance.seubanco.vpc_security_groups[0]
  security_group_id        = aws_security_group.db_sg.id
  
  # Origem: O ID que encontramos no passo 1
  source_security_group_id = tolist(data.aws_security_groups.eks_nodes.ids)[0]
  
  description              = "Libera acesso dos Nodes do EKS ao RDS"
}

resource "aws_security_group_rule" "allow_lambda_to_rds" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"

  security_group_id        = aws_security_group.db_sg.id
  source_security_group_id = data.terraform_remote_state.lambda.outputs.lambda_security_group_id

  description = "Libera acesso da Lambda ao RDS"
}
