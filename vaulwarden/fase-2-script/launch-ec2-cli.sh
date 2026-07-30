#!/bin/bash

################################################################################
# Script para Lanzar EC2 con Vaultwarden desde AWS CLI
################################################################################
#
# Descripción:
#   Este script lanza una instancia EC2 con Vaultwarden usando AWS CLI.
#   Útil para usuarios que prefieren la línea de comandos sobre la consola web.
#
# Prerequisitos:
#   - AWS CLI instalado y configurado (aws configure)
#   - Par de claves SSH creado en AWS
#   - Permisos para crear instancias EC2 y Security Groups
#
# Uso:
#   ./launch-ec2-cli.sh
#
# Autor: Roberto Flores - AWS User Group Playa Vicente
# Contacto: https://linktr.ee/siegfried.fs
# Versión: 1.0
# Fecha: 2026-02-21
#
################################################################################

################################################################################
# CONFIGURACIÓN - MODIFICA ESTAS VARIABLES
################################################################################

# Nombre de tu par de claves SSH (debe existir en AWS)
KEY_NAME="vaultwarden-key"

# Región de AWS
REGION="us-east-1"

# Tipo de instancia (t2.micro es Free Tier eligible)
INSTANCE_TYPE="t2.micro"

# AMI de Amazon Linux 2023 (actualiza según tu región)
# Para encontrar la AMI más reciente: aws ec2 describe-images --owners amazon --filters "Name=name,Values=al2023-ami-*" --query 'Images[0].ImageId'
AMI_ID="ami-0c02fb55b34f3b1f2"  # Amazon Linux 2023 en us-east-1

# Nombre para identificar la instancia
INSTANCE_NAME="Vaultwarden-CLI"

# Tipo de instalación: "http" o "https"
INSTALL_TYPE="http"  # Cambia a "https" si tienes dominio configurado

# Solo para INSTALL_TYPE="https"
DOMAIN="vault.tudominio.com"
EMAIL="tu@email.com"
SMTP_HOST="smtp.gmail.com"
SMTP_USERNAME="tu@gmail.com"
SMTP_PASSWORD="tu-contraseña-de-app"

################################################################################
# NO MODIFICAR DEBAJO DE ESTA LÍNEA
################################################################################

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para logging
log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

################################################################################
# VALIDACIONES
################################################################################

log "Validando prerequisitos..."

# Verificar que AWS CLI está instalado
if ! command -v aws &> /dev/null; then
    error "AWS CLI no está instalado. Instálalo desde: https://aws.amazon.com/cli/"
fi

# Verificar que AWS CLI está configurado
if ! aws sts get-caller-identity &> /dev/null; then
    error "AWS CLI no está configurado. Ejecuta: aws configure"
fi

log "✓ AWS CLI configurado correctamente"

# Verificar que el par de claves existe
if ! aws ec2 describe-key-pairs --key-names "$KEY_NAME" --region "$REGION" &> /dev/null; then
    error "El par de claves '$KEY_NAME' no existe en la región $REGION. Créalo primero o cambia KEY_NAME."
fi

log "✓ Par de claves '$KEY_NAME' encontrado"

################################################################################
# CREAR SECURITY GROUP
################################################################################

log "Creando Security Group..."

# Nombre único para el Security Group
SG_NAME="vaultwarden-sg-$(date +%s)"
SG_DESCRIPTION="Security Group para Vaultwarden - Creado por CLI"

# Crear Security Group
SG_ID=$(aws ec2 create-security-group \
    --group-name "$SG_NAME" \
    --description "$SG_DESCRIPTION" \
    --region "$REGION" \
    --query 'GroupId' \
    --output text 2>/dev/null)

if [ -z "$SG_ID" ]; then
    error "No se pudo crear el Security Group"
fi

log "✓ Security Group creado: $SG_ID"

# Agregar reglas de entrada
log "Configurando reglas del Security Group..."

# SSH (22)
aws ec2 authorize-security-group-ingress \
    --group-id "$SG_ID" \
    --protocol tcp \
    --port 22 \
    --cidr 0.0.0.0/0 \
    --region "$REGION" &> /dev/null

# HTTP (80)
aws ec2 authorize-security-group-ingress \
    --group-id "$SG_ID" \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0 \
    --region "$REGION" &> /dev/null

# HTTPS (443)
aws ec2 authorize-security-group-ingress \
    --group-id "$SG_ID" \
    --protocol tcp \
    --port 443 \
    --cidr 0.0.0.0/0 \
    --region "$REGION" &> /dev/null

log "✓ Reglas configuradas (SSH: 22, HTTP: 80, HTTPS: 443)"

################################################################################
# PREPARAR USER DATA
################################################################################

log "Preparando script de instalación..."

if [ "$INSTALL_TYPE" = "https" ]; then
    # Leer el script HTTPS y reemplazar variables
    if [ ! -f "install-vaultwarden-https.sh" ]; then
        error "No se encuentra install-vaultwarden-https.sh en el directorio actual"
    fi
    
    USER_DATA=$(cat install-vaultwarden-https.sh | \
        sed "s/DOMAIN=\".*\"/DOMAIN=\"$DOMAIN\"/" | \
        sed "s/EMAIL=\".*\"/EMAIL=\"$EMAIL\"/" | \
        sed "s/SMTP_HOST=\".*\"/SMTP_HOST=\"$SMTP_HOST\"/" | \
        sed "s/SMTP_USERNAME=\".*\"/SMTP_USERNAME=\"$SMTP_USERNAME\"/" | \
        sed "s/SMTP_PASSWORD=\".*\"/SMTP_PASSWORD=\"$SMTP_PASSWORD\"/")
    
    log "✓ Usando instalación HTTPS con dominio: $DOMAIN"
else
    # Leer el script HTTP
    if [ ! -f "install-vaultwarden.sh" ]; then
        error "No se encuentra install-vaultwarden.sh en el directorio actual"
    fi
    
    USER_DATA=$(cat install-vaultwarden.sh)
    log "✓ Usando instalación HTTP (sin SSL)"
fi

################################################################################
# LANZAR INSTANCIA EC2
################################################################################

log "Lanzando instancia EC2..."

INSTANCE_ID=$(aws ec2 run-instances \
    --image-id "$AMI_ID" \
    --instance-type "$INSTANCE_TYPE" \
    --key-name "$KEY_NAME" \
    --security-group-ids "$SG_ID" \
    --user-data "$USER_DATA" \
    --region "$REGION" \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$INSTANCE_NAME}]" \
    --query 'Instances[0].InstanceId' \
    --output text 2>/dev/null)

if [ -z "$INSTANCE_ID" ]; then
    error "No se pudo lanzar la instancia EC2"
fi

log "✓ Instancia lanzada: $INSTANCE_ID"

################################################################################
# ESPERAR A QUE LA INSTANCIA ESTÉ CORRIENDO
################################################################################

log "Esperando a que la instancia esté corriendo..."

aws ec2 wait instance-running \
    --instance-ids "$INSTANCE_ID" \
    --region "$REGION"

log "✓ Instancia corriendo"

################################################################################
# OBTENER IP PÚBLICA
################################################################################

log "Obteniendo IP pública..."

PUBLIC_IP=$(aws ec2 describe-instances \
    --instance-ids "$INSTANCE_ID" \
    --region "$REGION" \
    --query 'Reservations[0].Instances[0].PublicIpAddress' \
    --output text)

if [ -z "$PUBLIC_IP" ] || [ "$PUBLIC_IP" = "None" ]; then
    error "No se pudo obtener la IP pública"
fi

log "✓ IP pública: $PUBLIC_IP"

################################################################################
# INFORMACIÓN FINAL
################################################################################

echo ""
echo "=========================================="
echo "  Instancia EC2 Lanzada Exitosamente"
echo "=========================================="
echo ""
echo "Información de la instancia:"
echo "  Instance ID:    $INSTANCE_ID"
echo "  IP Pública:     $PUBLIC_IP"
echo "  Security Group: $SG_ID"
echo "  Región:         $REGION"
echo "  Tipo:           $INSTANCE_TYPE"
echo ""

if [ "$INSTALL_TYPE" = "https" ]; then
    echo "Acceso:"
    echo "  URL:  https://$DOMAIN"
    echo ""
    echo "Nota: Espera 3-5 minutos para que el script de instalación termine."
    echo "      Caddy necesitará 1-2 minutos adicionales para obtener el certificado SSL."
else
    echo "Acceso:"
    echo "  URL:  http://$PUBLIC_IP"
    echo ""
    echo "Nota: Espera 3-5 minutos para que el script de instalación termine."
fi

echo ""
echo "Conectar por SSH:"
echo "  ssh -i ~/.ssh/$KEY_NAME.pem ec2-user@$PUBLIC_IP"
echo ""
echo "Ver logs de instalación:"
echo "  ssh -i ~/.ssh/$KEY_NAME.pem ec2-user@$PUBLIC_IP 'cat /var/log/vaultwarden-install.log'"
echo ""
echo "Comandos útiles:"
echo "  # Ver estado de la instancia"
echo "  aws ec2 describe-instances --instance-ids $INSTANCE_ID --region $REGION"
echo ""
echo "  # Detener la instancia"
echo "  aws ec2 stop-instances --instance-ids $INSTANCE_ID --region $REGION"
echo ""
echo "  # Terminar la instancia"
echo "  aws ec2 terminate-instances --instance-ids $INSTANCE_ID --region $REGION"
echo ""
echo "  # Eliminar Security Group (después de terminar la instancia)"
echo "  aws ec2 delete-security-group --group-id $SG_ID --region $REGION"
echo ""
echo "=========================================="
echo ""

# Guardar información en archivo
INFO_FILE="ec2-instance-info-$(date +%Y%m%d-%H%M%S).txt"
cat > "$INFO_FILE" <<EOF
Instancia EC2 de Vaultwarden
Creada: $(date)

Instance ID: $INSTANCE_ID
IP Pública: $PUBLIC_IP
Security Group: $SG_ID
Región: $REGION
Tipo de Instancia: $INSTANCE_TYPE
Par de Claves: $KEY_NAME

Acceso SSH:
ssh -i ~/.ssh/$KEY_NAME.pem ec2-user@$PUBLIC_IP

URL de Acceso:
EOF

if [ "$INSTALL_TYPE" = "https" ]; then
    echo "https://$DOMAIN" >> "$INFO_FILE"
else
    echo "http://$PUBLIC_IP" >> "$INFO_FILE"
fi

cat >> "$INFO_FILE" <<EOF

Comandos de Limpieza:
# Terminar instancia
aws ec2 terminate-instances --instance-ids $INSTANCE_ID --region $REGION

# Eliminar Security Group (después de terminar)
aws ec2 delete-security-group --group-id $SG_ID --region $REGION
EOF

log "✓ Información guardada en: $INFO_FILE"

echo ""
log "¡Listo! Tu instancia de Vaultwarden está en proceso de instalación."
echo ""

exit 0
