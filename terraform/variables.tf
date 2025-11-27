# Archivo: terraform/variables.tf

# Región de AWS (Ohio)
variable "aws_region" {
  description = "La región de AWS para desplegar Lightsail (us-east-2 = Ohio)."
  type        = string
  default     = "us-east-2"
}

# Nombre de la clave SSH existente en Lightsail/IAM (Clave Pública)
variable "ssh_key_name" {
  description = "El nombre exacto de la clave pública SSH registrada en Lightsail."
  type        = string
  default     = "terraform" 
}

# 🔑 NUEVA VARIABLE: RUTA DE LA CLAVE PRIVADA LOCAL (Para Ansible)
variable "ansible_ssh_key_path" {
  description = "Ruta completa a la clave privada SSH local (.pem) usada por Ansible."
  type        = string
  default     = "~/.ssh/terraform.pem" 
}

# Blueprint (Sistema Operativo)
variable "os_blueprint" {
  description = "El ID del Blueprint para el sistema operativo."
  type        = string
  default     = "ubuntu_22_04" # Ubuntu 22.04 LTS
}

# Conteo de Workers
variable "worker_count" {
  description = "Número de nodos worker a desplegar."
  type        = number
  default     = 2
}