#!/bin/bash

################################################################################
# Script de Instalación de Vaultwarden para AWS EC2
################################################################################
#
# Descripción:
#   Este script automatiza la instalación de Vaultwarden en una instancia
#   EC2 de Amazon Linux 2. Instala Docker, configura el servicio y lanza
#   el contenedor de Vaultwarden.
#
# Uso:
#   1. Copiar este script completo
#   2. Pegarlo en el campo "User Data" al lanzar una instancia EC2
#   3. La instancia se configurará automáticamente al iniciar
#
# Requisitos:
#   - Amazon Linux 2 o Amazon Linux 2023 AMI
#   - Instancia t2.micro o superior
#   - Security Group con puertos 80, 443 y 22 abiertos
#
# Autor: Roberto Flores - AWS User Group Playa Vicente
# Contacto: https://linktr.ee/siegfried.fs
# Versión: 1.0
# Fecha: 2026-02-21
#
################################################################################

# Configuración de logging
LOG_FILE="/var/log/vaultwarden-install.log"
exec 1> >(tee -a "$LOG_FILE")
exec 2>&1

# Función para logging con timestamp
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Función para manejo de errores
error_exit() {
    log "ERROR: $1"
    exit 1
}

log "=========================================="
log "Iniciando instalación de Vaultwarden"
log "Versión del script: 1.0"
log "=========================================="

################################################################################
# PASO 1 y 2: Detectar sistema operativo e instalar Docker
################################################################################
log "Paso 1 y 2: Detectando sistema operativo e instalando Docker..."

if command -v apt-get &>/dev/null; then
    log "Detectado: Ubuntu / Debian"
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -y || error_exit "Falló apt-get update"
    apt-get install -y docker.io curl git ca-certificates || error_exit "Falló instalación de Docker en Ubuntu"
elif command -v dnf &>/dev/null; then
    log "Detectado: Amazon Linux 2023 / Fedora / RHEL"
    dnf update -y
    dnf install -y docker curl git || error_exit "Falló instalación de Docker con dnf"
elif command -v yum &>/dev/null; then
    log "Detectado: Amazon Linux 2 / CentOS"
    yum update -y
    if grep -q "Amazon Linux 2" /etc/os-release; then
        amazon-linux-extras install docker -y || yum install -y docker
    else
        yum install -y docker
    fi
else
    error_exit "Gestor de paquetes no reconocido (apt-get/dnf/yum)"
fi

log "✓ Docker instalado correctamente"

################################################################################
# PASO 3: Iniciar y habilitar el servicio Docker
################################################################################
log "Paso 3: Configurando servicio Docker..."

systemctl start docker || error_exit "Falló al iniciar Docker"
systemctl enable docker || error_exit "Falló al habilitar Docker"
systemctl is-active --quiet docker || error_exit "Docker no está corriendo"

log "✓ Servicio Docker iniciado y habilitado"

################################################################################
# PASO 4: Agregar usuarios al grupo docker
################################################################################
log "Paso 4: Configurando permisos de usuario..."

for u in ubuntu ec2-user admin centos; do
    if id "$u" &>/dev/null; then
        usermod -aG docker "$u" && log "✓ Usuario $u agregado al grupo docker"
    fi
done

################################################################################
# PASO 5: Crear directorio para datos persistentes
################################################################################
log "Paso 5: Creando directorio de datos..."

mkdir -p /vw-data || error_exit "Falló la creación del directorio de datos"
chmod 755 /vw-data
log "✓ Directorio de datos creado: /vw-data"

################################################################################
# PASO 6: Descargar imagen de Vaultwarden
################################################################################
log "Paso 6: Descargando imagen de Vaultwarden..."

docker pull vaultwarden/server:latest || error_exit "Falló la descarga de la imagen de Vaultwarden"
log "✓ Imagen de Vaultwarden descargada"

################################################################################
# PASO 7: Obtener IP pública (IMDSv2 + Fallback)
################################################################################
log "Paso 7: Obteniendo IP pública (IMDSv2 / External API)..."

PUBLIC_IP=""
# Intentar IMDSv2 Token primero
TOKEN=$(curl -s -f -m 3 -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 60" 2>/dev/null)
if [ -n "$TOKEN" ]; then
    PUBLIC_IP=$(curl -s -f -m 3 -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null)
fi

# Fallback IMDSv1
if [ -z "$PUBLIC_IP" ]; then
    PUBLIC_IP=$(curl -s -f -m 3 http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null)
fi

# Fallback External Services
if [ -z "$PUBLIC_IP" ]; then
    PUBLIC_IP=$(curl -s -f -m 3 https://ifconfig.me 2>/dev/null || curl -s -f -m 3 https://api.ipify.org 2>/dev/null)
fi

if [ -z "$PUBLIC_IP" ]; then
    log "ADVERTENCIA: No se pudo obtener la IP pública automáticamente, usando localhost"
    PUBLIC_IP="localhost"
else
    log "✓ IP pública obtenida: $PUBLIC_IP"
fi

################################################################################
# PASO 8: Lanzar contenedor de Vaultwarden
################################################################################
log "Paso 8: Lanzando contenedor de Vaultwarden..."

if docker ps -a | grep -q vaultwarden; then
    log "Contenedor existente detectado, eliminando..."
    docker stop vaultwarden 2>/dev/null || true
    docker rm vaultwarden 2>/dev/null || true
    log "✓ Contenedor anterior eliminado"
fi

# Variables opcionales de Zoho SMTP (si están presentes en el entorno)
ZOHO_SMTP_ENV=""
if [ -n "$ZOHO_EMAIL" ] && [ -n "$ZOHO_PASSWORD" ]; then
    log "Configurando Zoho Mail SMTP para notificaciones..."
    ZOHO_SMTP_ENV="-e SMTP_HOST=smtp.zoho.com -e SMTP_FROM=$ZOHO_EMAIL -e SMTP_PORT=587 -e SMTP_SECURITY=starttls -e SMTP_USERNAME=$ZOHO_EMAIL -e SMTP_PASSWORD=$ZOHO_PASSWORD"
fi

docker run -d \
  --name vaultwarden \
  -e DOMAIN="http://$PUBLIC_IP" \
  -e ROCKET_PORT=80 \
  -e SIGNUPS_ALLOWED=true \
  -e WEBSOCKET_ENABLED=true \
  -e I_REALLY_WANT_VOLATILE_STORAGE=true \
  $ZOHO_SMTP_ENV \
  -p 80:80 \
  -v /vw-data/:/data/ \
  --restart unless-stopped \
  vaultwarden/server:latest || error_exit "Falló el lanzamiento del contenedor"
  -p 80:80 \
  -v /vw-data/:/data/ \
  --restart unless-stopped \
  vaultwarden/server:latest || error_exit "Falló el lanzamiento del contenedor"

log "✓ Contenedor de Vaultwarden lanzado con configuración HTTP (modo desarrollo)"

################################################################################
# PASO 9: Verificar que el contenedor está corriendo
################################################################################
log "Paso 9: Verificando instalación..."

# Esperar unos segundos para que el contenedor inicie
sleep 5

# Verificar que el contenedor está corriendo
if docker ps | grep -q vaultwarden; then
    log "✓ Contenedor de Vaultwarden está corriendo correctamente"
else
    error_exit "El contenedor de Vaultwarden no está corriendo"
fi

# Verificar que el puerto 80 está escuchando
if netstat -tlnp | grep -q ':80'; then
    log "✓ Puerto 80 está escuchando"
else
    log "ADVERTENCIA: El puerto 80 no parece estar escuchando"
fi

################################################################################
# PASO 10: Mostrar información de la instalación
################################################################################
log "=========================================="
log "Instalación completada exitosamente"
log "=========================================="

log ""
log "Información de acceso:"
log "  URL: http://$PUBLIC_IP"
log "  Contenedor: vaultwarden"
log "  Datos: /vw-data/"
log ""
log "Para ver los logs del contenedor:"
log "  docker logs vaultwarden"
log ""
log "Para ver este log de instalación:"
log "  cat $LOG_FILE"
log ""
log "¡Vaultwarden está listo para usar!"
log "=========================================="

################################################################################
# PASO 11: Crear archivo de estado
################################################################################

# Crear archivo indicando que la instalación se completó
echo "Instalación completada: $(date)" > /var/lib/cloud/instance/vaultwarden-installed

log "Archivo de estado creado"

################################################################################
# FIN DEL SCRIPT
################################################################################

exit 0
