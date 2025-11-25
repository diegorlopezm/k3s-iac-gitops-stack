# Archivo: terraform/variables.tf

# Región de AWS (Ohio)
variable "aws_region" {
  description = "La región de AWS para desplegar Lightsail (us-east-2 = Ohio)."
  type        = string
  default     = "us-east-2"
}

# Nombre de la clave SSH existente en Lightsail/IAM
variable "ssh_key_name" {
  description = "El nombre exacto de la clave SSH que deseas usar para el acceso."
  type        = string
  # ¡IMPORTANTE!: Reemplaza "TU_CLAVE_SSH_REAL" con el nombre de tu clave SSH de AWS
  default     = "terraform" 
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