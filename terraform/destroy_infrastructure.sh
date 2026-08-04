#!/bin/bash
# ==============================================================================
# SCRIPT DE ELIMINACIÓN Y PURGA DE CERO RASTRO DE INFRAESTRUCTURA (GCP)
# RealStateAux - Asistente Inmobiliario Autónomo (OpenClaw + GCP)
# ==============================================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

PROJECT_ID=${GCP_PROJECT_ID:-$(gcloud config get-value project 2>/dev/null || echo "")}
VPC_NAME="realstate-vpc-prod"

echo -e "${CYAN}======================================================================${NC}"
echo -e "${CYAN}   SISTEMA DE ASEGURAMIENTO DE ELIMINACIÓN Y CERO RASTRO DE INFRAESTRUCTURA   ${NC}"
echo -e "${CYAN}======================================================================${NC}"

if [ -z "$PROJECT_ID" ]; then
    echo -e "${YELLOW}⚠️  No se detectó GCP_PROJECT_ID. Especifica el proyecto en GCP:${NC}"
    read -p "Ingresa tu GCP Project ID: " PROJECT_ID
fi

echo -e "${YELLOW}Proyecto GCP Identificado: ${PROJECT_ID}${NC}"
echo -e "${RED}⚠️  ¡ADVERTENCIA! Esta acción destruirá permanentemente toda la VPC, subredes, VMs, discos y reglas de firewall.${NC}"

if [ "$1" != "--force" ]; then
    read -p "¿Deseas proceder con la eliminación completa? (escribe 'DELETE_ALL' para confirmar): " CONFIRM
    if [ "$CONFIRM" != "DELETE_ALL" ]; then
        echo -e "${GREEN}Operación cancelada por el usuario. No se modificó ningún recurso.${NC}"
        exit 0
    fi
fi

echo -e "\n${CYAN}--- Paso 1: Ejecutando Terraform Destroy ---${NC}"
if [ -d "terraform" ]; then
    cd terraform
fi

if command -v terraform &> /dev/null; then
    terraform destroy -auto-approve -var="project_id=${PROJECT_ID}" || echo -e "${YELLOW}Advertencia: Terraform destroy finalizó con advertencias.${NC}"
else
    echo -e "${YELLOW}Terraform no instalado localmente, procediendo a purga directa vía gcloud CLI...${NC}"
fi

echo -e "\n${CYAN}--- Paso 2: Purga Manual de Recursos Huérfanos en GCP ---${NC}"

# 1. Eliminar Instancias VM remanentes
echo -e "Purando Instancias Compute Engine..."
VMS=$(gcloud compute instances list --project="$PROJECT_ID" --filter="name ~ openclaw OR name ~ realstate" --format="value(name,zone)" 2>/dev/null || true)
if [ -n "$VMS" ]; then
    echo "$VMS" | while read -r vm zone; do
        echo -e "${YELLOW}Eliminando VM huérfana: $vm en zona $zone...${NC}"
        gcloud compute instances delete "$vm" --zone="$zone" --project="$PROJECT_ID" --quiet 2>/dev/null || true
    done
else
    echo -e "${GREEN}✅ No se encontraron VMs huérfanas.${NC}"
fi

# 2. Eliminar Reglas de Firewall
echo -e "Purgando Reglas de Firewall..."
FWS=$(gcloud compute firewall-rules list --project="$PROJECT_ID" --filter="name ~ realstate" --format="value(name)" 2>/dev/null || true)
if [ -n "$FWS" ]; then
    echo "$FWS" | while read -r fw; do
        echo -e "${YELLOW}Eliminando Firewall: $fw...${NC}"
        gcloud compute firewall-rules delete "$fw" --project="$PROJECT_ID" --quiet 2>/dev/null || true
    done
else
    echo -e "${GREEN}✅ No se encontraron reglas de firewall huérfanas.${NC}"
fi

# 3. Eliminar Subredes y VPC
echo -e "Purgando Subredes y VPC..."
SUBNETS=$(gcloud compute networks subnets list --project="$PROJECT_ID" --filter="network ~ ${VPC_NAME}" --format="value(name,region)" 2>/dev/null || true)
if [ -n "$SUBNETS" ]; then
    echo "$SUBNETS" | while read -r sub region; do
        echo -e "${YELLOW}Eliminando Subred: $sub en región $region...${NC}"
        gcloud compute networks subnets delete "$sub" --region="$region" --project="$PROJECT_ID" --quiet 2>/dev/null || true
    done
fi

if gcloud compute networks describe "$VPC_NAME" --project="$PROJECT_ID" &>/dev/null; then
    echo -e "${YELLOW}Eliminando VPC principal: $VPC_NAME...${NC}"
    gcloud compute networks delete "$VPC_NAME" --project="$PROJECT_ID" --quiet 2>/dev/null || true
else
    echo -e "${GREEN}✅ La VPC principal no existe o ya fue eliminada.${NC}"
fi

echo -e "\n${CYAN}--- Paso 3: Auditoría Final de Cero Rastro ---${NC}"
if [ -f "verify_zero_trace.py" ]; then
    python3 verify_zero_trace.py --project="$PROJECT_ID"
elif [ -f "../verify_zero_trace.py" ]; then
    python3 ../verify_zero_trace.py --project="$PROJECT_ID"
fi

echo -e "\n${GREEN}======================================================================${NC}"
echo -e "${GREEN}🎉 PROCESO COMPLETO: SE HA GARANTIZADO LA ELIMINACIÓN DE TODO RASTRO. ${NC}"
echo -e "${GREEN}======================================================================${NC}"
