# Archivo: terraform/main.tf

# 1. Configuración del Proveedor (AWS)
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# 2. Configuración del Proveedor de AWS
# La región debe ser us-east-2 (Ohio) para todos los recursos
provider "aws" {
  region = var.aws_region
}

# --- NAVE MASTER (2 GB RAM, 2 vCPUs, 60 GB SSD) ---
resource "aws_lightsail_instance" "k3s_master" {
  name              = "k3s-master-1"
  # Bundle ID: large_2_0 es el que corresponde a las especificaciones
  bundle_id         = "large_2_0" 
  
  availability_zone = "${var.aws_region}a" # Usamos la Zona A de Ohio
  blueprint_id      = var.os_blueprint     # Ubuntu 22.04 LTS
  key_pair_name     = var.ssh_key_name     # Nombre de tu clave IAM
  tags = {
    Name = "k3s-master-1"
    Role = "master"
  }
}

# --- NAVES WORKER (1 GB RAM, 2 vCPUs, 40 GB SSD) ---
resource "aws_lightsail_instance" "k3s_workers" {
  count             = var.worker_count # Crea 2 workers
  name              = "k3s-worker-${count.index + 1}"
  # Bundle ID: medium_2_0 es el que corresponde a las especificaciones
  bundle_id         = "medium_2_0" 
  
  availability_zone = "${var.aws_region}a"
  blueprint_id      = var.os_blueprint
  key_pair_name     = var.ssh_key_name
  tags = {
    Name = "k3s-worker-${count.index + 1}"
    Role = "worker"
  }
}