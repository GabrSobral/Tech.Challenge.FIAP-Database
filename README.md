# Infraestrutura de Dados (RDS) - Tech Challenge

Este repositório contém o código Terraform responsável pelo provisionamento da camada de persistência de dados do projeto **Tech Challenge**. O foco é a criação de um banco de dados relacional gerenciado e seguro, integrado às demais camadas da aplicação (Kubernetes e Serverless).

## 📑 Sumário

- [Objetivo](#-objetivo)
- [Tecnologias e Requisitos Técnicos](#-tecnologias-e-requisitos-técnicos)
- [Getting Started](#-getting-started)
- [Recursos Criados pelo Terraform](#-recursos-criados-pelo-terraform)
  - [Banco de Dados (RDS)](#1-banco-de-dados-rds)
  - [Segurança e Segredos](#2-segurança-e-segredos)
  - [Rede e Integrações](#3-rede-e-integrações)
- [Como Rodar](#️-como-rodar)

---

## 🎯 Objetivo

O objetivo deste projeto é isolar a camada de dados, garantindo que o estado da aplicação seja persistido de forma independente do ciclo de vida dos containers. A infraestrutura provisiona:
* Uma instância de banco de dados PostgreSQL gerenciada pela AWS.
* Gerenciamento automático de credenciais (Senhas).
* Regras de firewall para permitir conexão apenas de fontes confiáveis (Cluster EKS e Lambdas).

## 🛠 Tecnologias e Requisitos Técnicos

As seguintes tecnologias e providers foram utilizados:

* [cite_start]**IaC:** [Terraform](https://www.terraform.io/) (versão >= 1.6.0)[cite: 33].
* [cite_start]**Banco de Dados:** AWS RDS (PostgreSQL 17.4)
* **Gerenciamento de Segredos:** AWS Secrets Manager.
* **Estado Remoto:** Integração via `terraform_remote_state` para leitura de outputs de outros repositórios.

## 🚀 Getting Started

### Pré-requisitos
Para executar este projeto, é necessário ter:

1.  **AWS CLI** e **Terraform** instalados.
2.  **Dependência de Infraestrutura:** Este repositório depende que outras infraestruturas já tenham sido criadas, pois ele consulta o estado remoto (`terraform_remote_state`) para buscar:
    * [cite_start]A **VPC e Subnets** (do repositório de Kubernetes)[cite: 34].
    * [cite_start]O **Security Group da Lambda** (do repositório de Autenticação)[cite: 34].
3.  [cite_start]Certifique-se de que o arquivo `data.tf` aponta para o bucket S3 correto onde os estados anteriores foram salvos (`tech-challenge-fiap-s3-bucket`)[cite: 34].

## 📦 Recursos Criados pelo Terraform

### 1. Banco de Dados (RDS)
* **Engine:** PostgreSQL versão **17.4**.
* [cite_start]**Instância:** Classe `db.t4g.micro` (elegível ao AWS Free Tier) com 20GB de armazenamento `gp2`.
* **Identificador:** `tech-challenge-db`.
* [cite_start]**Configuração:** O banco é criado com acessibilidade pública (`publicly_accessible = true`) para fins de desenvolvimento/teste.

### 2. Segurança e Segredos
* **Secrets Manager:** A senha do banco de dados não é exposta diretamente no código (exceto valor inicial); [cite_start]é criado um segredo `db_password` no AWS Secrets Manager.
* **Security Group (DB SG):** Firewall exclusivo para o banco de dados.

### 3. Rede e Integrações
O Security Group do banco é configurado dinamicamente para aceitar conexões na porta **5432** (TCP) apenas de:
* [cite_start]**Cluster EKS:** Identifica automaticamente o Security Group dos nós do cluster através de tags (`kubernetes.io/cluster/...`)[cite: 38, 52].
* [cite_start]**AWS Lambda:** Libera acesso para a função Lambda de autenticação, recuperando o ID do grupo de segurança via *Remote State*[cite: 54].

## ▶️ Como Rodar

1.  **Inicialize o Terraform:**
    Isso baixará os providers e configurará o backend S3.
    ```bash
    terraform init
    ```

2.  **Verifique o Plano:**
    O Terraform irá ler o estado remoto da VPC e da Lambda para planejar a criação do banco na rede correta.
    ```bash
    terraform plan
    ```

3.  **Aplique a Infraestrutura:**
    Cria o banco de dados e as regras de segurança.
    ```bash
    terraform apply --auto-approve
    ```

4.  **Outputs:**
    Ao final, o Terraform exibirá informações úteis para conexão, como:
    * `rds_endpoint`: O endereço do host do banco[cite: 50].
    * `db_secret_name`: O nome do segredo onde a senha está guardada[cite: 50].