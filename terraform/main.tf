# Archivo: terraform/main.tf
# Este archivo define la infraestructura (3 VMs Lightsail) y automatiza el
# despliegue de configuración (K3S) a través de Ansible.

# 1. Configuración del Proveedor (AWS)
# Define la versión mínima requerida del proveedor de AWS (IaC).
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# 2. Configuración del Proveedor de AWS
# Indica a Terraform la región de AWS donde se crearán los recursos.
provider "aws" {
  region = var.aws_region # Usamos la variable definida en variables.tf (us-east-2)
}

# --- RECURSO: NAVE MASTER (k3s-master-1) ---
resource "aws_lightsail_instance" "k3s_master" {
  name              = "k3s-master-1"
  # Bundle ID para 2 GB RAM, 1 vCPU, 60 GB SSD (o similar).
  # Usaremos 'medium_2_0' (2GB RAM) para el Master, ajustando según la necesidad.
  bundle_id         = "medium_2_0" # Bundle recomendado para 2GB RAM
  
  availability_zone = "${var.aws_region}a" # Zona de disponibilidad (ej: us-east-2a)
  blueprint_id      = var.os_blueprint     # Sistema Operativo (Ubuntu 22.04 LTS)
  key_pair_name     = var.ssh_key_name     # Nombre de la clave SSH para acceso
  tags = {
    Name = "k3s-master-1"
    Role = "master" # Tag crucial para identificar el rol
  }
  # 🔴 ¡CORRECCIÓN AQUÍ!
  # El Master DEBE esperar a que los Workers existan antes de que el provisioner se ejecute.
  # 'depends_on' se define en el nivel del recurso, no del provisioner.
  depends_on = [
    aws_lightsail_instance.k3s_workers
  ]
  # ----------------------------------------------------------------------
  # 3. PROVISIONER: Automatización con Ansible
  # Este bloque se ejecuta DESPUÉS de que el nodo Master se crea exitosamente.
  # Se encarga de generar el inventario dinámico con IPs nuevas y de lanzar Ansible.
  # ----------------------------------------------------------------------
provisioner "local-exec" {
    command = <<-EOT
      # ⏳ ESPERAR para asegurar que el servicio SSH esté activo en el Master.
      echo "Esperando 30 segundos para el arranque de SSH..."
      sleep 60
      # Rutas y Variables
      INVENTORY="../ansible/hosts_auto.ini"
      SSH_KEY="${var.ansible_ssh_key_path}" 
      MASTER_PUBLIC_IP="${aws_lightsail_instance.k3s_master.public_ip_address}" 

      # Limpiamos y recreamos la cabecera (SIN PROXY COMMAND GLOBAL)
      echo "[all:vars]" > $INVENTORY
      echo "ansible_user=ubuntu" >> $INVENTORY
      echo "ansible_ssh_private_key_file=$SSH_KEY" >> $INVENTORY
      echo "ansible_ssh_common_args='-o StrictHostKeyChecking=no'" >> $INVENTORY
      
      
      # Escribir la IP del Master (¡USAR IP PÚBLICA PARA EL ACCESO INICIAL!)
      echo "" >> $INVENTORY
      echo "[k3s_master]" >> $INVENTORY
      echo "${self.public_ip_address}" >> $INVENTORY  # ✅ CORREGIDO: Usar IP Pública
      
      # Escribir las IPs privadas de los Workers
      echo "" >> $INVENTORY
      echo "[k3s_workers]" >> $INVENTORY
      echo -e "${join("\n", formatlist("%s", aws_lightsail_instance.k3s_workers.*.private_ip_address))}" >> $INVENTORY
      
      # 🔑 NUEVO GRUPO: PROXY COMMAND SOLO PARA WORKERS 🔑
      echo "" >> $INVENTORY
      echo "[k3s_workers:vars]" >> $INVENTORY
      echo "ansible_ssh_common_args='-o StrictHostKeyChecking=no -o ProxyCommand=\"ssh -W %h:%p -q ubuntu@$MASTER_PUBLIC_IP -i $SSH_KEY\"'" >> $INVENTORY
      echo "ansible_ssh_timeout=60" >> $INVENTORY

      # 🚀 LANZAR EL PLAYBOOK
      echo "Iniciando Ansible Playbook para configurar K3S..."
      ansible-playbook -i $INVENTORY ../ansible/playbooks/test_connection.yml
    EOT
  }
}
# --- RECURSO: NAVES WORKER (k3s-worker-1 y k3s-worker-2) ---
resource "aws_lightsail_instance" "k3s_workers" {
  count             = var.worker_count # Crea 2 workers según variable
  name              = "k3s-worker-${count.index + 1}"
  # Bundle ID para 1 GB RAM, 1 vCPU, 40 GB SSD (o similar).
  # Usaremos 'small_2_0' (1GB RAM) para Workers.
  bundle_id         = "small_2_0" # Bundle recomendado para 1GB RAM
  
  availability_zone = "${var.aws_region}a"
  blueprint_id      = var.os_blueprint
  key_pair_name     = var.ssh_key_name
  tags = {
    Name = "k3s-worker-${count.index + 1}"
    Role = "worker" # Tag crucial para identificar el rol
  }
  # Nota: El provisionamiento de estos nodos es manejado por Ansible, 
  # quien recibe las instrucciones lanzadas desde el provisioner del Master.
}