resource "aws_secretsmanager_secret" "db_password" {
  name = "db_password"
}

resource "aws_secretsmanager_secret_version" "db_password_version" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = "techchallenge123!"
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "tech-challenge-db-subnet-group"
  
  # AQUI ESTÁ O USO DO DATA SOURCE:
  subnet_ids = data.terraform_remote_state.vpc.outputs.subnet_ids

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_db_instance" "postgres_db" {
  # Identificador único para a instância RDS
  identifier = "tech-challenge-db"

  # Configurações do Banco de Dados
  engine            = "postgres"
  engine_version    = "17.4"
  instance_class    = "db.t4g.micro" # Classe de instância elegível para o Free Tier
  allocated_storage = 20            # Tamanho do armazenamento em GB (mínimo para Free Tier)
  storage_type      = "gp2"

  # Configurações de Conexão e Segurança
  db_name                = "techchallengedb" # Nome do banco de dados inicial a ser criado
  username               = "techchallenge"
  password               = aws_secretsmanager_secret_version.db_password_version.secret_string
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name

  # Configurações Adicionais
  publicly_accessible = true # Importante para segurança! O banco não deve ser acessível da internet.
  skip_final_snapshot = true  # Em produção, use 'false' para criar um snapshot final ao apagar.
}