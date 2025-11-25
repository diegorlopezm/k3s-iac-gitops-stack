# Archivo: terraform/output.tf

# Exporta la IP privada del nodo Master para el inventario de Ansible
output "master_ip" {
  description = "IP privada del nodo Master."
  value       = aws_lightsail_instance.k3s_master.private_ip_address
}

# Exporta las IPs privadas de los nodos Worker
output "worker_ips" {
  description = "IPs privadas de los nodos Worker."
  value       = aws_lightsail_instance.k3s_workers.*.private_ip_address
}