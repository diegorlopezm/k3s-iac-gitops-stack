# 🚀 k3s-iac-gitops-stack

## Infraestructura como Código (IaC), Observabilidad y GitOps en K3S

### 💡 Descripción del Proyecto

Este repositorio documenta y automatiza el despliegue de un clúster ligero de **Kubernetes (K3S)** desde cero. El proyecto implementa la metodología de **Infraestructura como Código (IaC)** y **GitOps** para gestionar la infraestructura, la configuración del cluster y el ciclo de vida de las aplicaciones.

El flujo de trabajo cubre el ciclo completo de la Plataforma SRE: Provisión, Configuración, Observabilidad y Entrega Continua.

### 🛠️ Stack Tecnológico Principal

| Categoría | Herramientas | Propósito |
| :--- | :--- | :--- |
| **Infraestructura** | **Terraform** (Provider AWS Lightsail) | Provisión inmutable de los 3 nodos (Master, 2 Workers) en la región de Ohio (`us-east-2`). |
| **Configuración** | **Ansible** | Orquestación post-provisionamiento para instalar y unir los nodos K3S automáticamente usando las IPs de Terraform. |
| **Cluster** | **K3S** | Plataforma Kubernetes ligera y compatible con Edge/Homelab. |
| **Observabilidad** | **Prometheus, Grafana, Loki** | Despliegue del stack completo de Métricas, Logs y Visualización (LPG Stack) mediante Helm. |
| **Automatización** | **ArgoCD** | Implementación de la metodología GitOps para sincronizar el estado del clúster con los manifiestos de este repositorio. |
| **Seguridad** | **HashiCorp Vault** | Gestión segura de secretos para aplicaciones desplegadas en K3S. |

### 🏗️ Arquitectura del Despliegue

El proyecto despliega la siguiente arquitectura:

1.  **Nube:** AWS Lightsail (us-east-2).
2.  **Nodos:** 1 Master (`large_2_0`), 2 Workers (`medium_2_0`).
3.  **Red:** Clúster interconectado vía IPs privadas.
4.  **Capa de Gestión:** Despliegue de ArgoCD, Prometheus, Grafana y Loki en el *namespace* `argocd` y `monitoring`.

[Placeholder para un diagrama de arquitectura simple: Terraform -> AWS -> Ansible -> K3S -> ArgoCD/Prometheus]

### ⚙️ Flujo de Trabajo (Workflow)

El despliegue se realiza en dos fases principales:

#### Fase 1: Provisión de la Infraestructura (Terraform)
1.  Define los recursos en `terraform/main.tf`.
2.  `terraform init`
3.  `terraform apply` (Crea los 3 VPS y exporta las IPs).

#### Fase 2: Configuración del Cluster (Ansible & GitOps)
1.  Ansible consume las IPs de Terraform para generar el inventario (`ansible/hosts.yml`).
2.  `ansible-playbook -i ansible/hosts.yml ansible/playbooks/install_k3s.yml` (Instala K3S y configura Master/Workers).
3.  Despliegue inicial de ArgoCD.
4.  ArgoCD asume el control: Sincroniza los manifiestos de `k8s-manifests/` (Observabilidad, Aplicaciones, etc.) con el estado del clúster.

### 💻 Requisitos Previos

* **Software:** Git, Terraform (v1.7+), Ansible (v2.9+), `kubectl`, `helm`.
* **Acceso AWS:** Credenciales de AWS configuradas localmente (perfil `default` o variables de entorno).
* **Clave SSH:** Una clave SSH con el mismo nombre (`mi-clave-ssh`) debe existir en AWS Lightsail.
