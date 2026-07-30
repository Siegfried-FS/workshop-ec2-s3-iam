#!/bin/bash

################################################################################
# Script de Instalación de Vaultwarden con HTTPS
################################################################################
#
# Descripción:
#   Este script instala Vaultwarden con HTTPS usando Caddy como reverse proxy.
#   Caddy obtiene y renueva certificados SSL automáticamente de Let's Encrypt.
#
# Requisitos:
#   - Amazon Linux 2 o Amazon Linux 2023
#   - Un dominio configurado en Route 53 (o cualquier DNS)
#   - Registro A apuntando a la IP pública de esta instancia
#   - Security Group con puertos 22, 80 y 443 abiertos
#   - DNS propagado (esperar 5-10 minutos después de crear el registro)
#
# Uso:
#   1. Modificar las variables DOMAIN y EMAIL abajo
#   2. Ejecutar: sudo ./install-vaultwarden-https.sh
#   3. Esperar 1-2 minutos para que Caddy obtenga el certificado
#   4. Acceder a: https://tu-dominio.com
#
# Autor: AWS User Group Workshop
# Versión: 1.0
# Fecha: 2024
#
################################################################################

################################################################################
# CONFIGURACIÓN - MODIFICA ESTAS VARIABLES
################################################################################

# Tu dominio completo (ej: vault.tudominio.com)
DOMAIN="vault.tudominio.com"

# Tu email para notificaciones de Let's Encrypt
EMAIL="tu@email.com"

################################################################################
# NO MODIFICAR DEBAJO DE ESTA LÍNEA
################################################################################

# Configuración de logging
LOG_FILE="/var/log/vaultwarden-https-install.log"
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
log "Instalación de Vaultwarden con HTTPS"
log "Versión del script: 1.0"
log "Dominio: $DOMAIN"
log "=========================================="

################################################################################
# VALIDACIONES PREVIAS
################################################################################
log "Validando configuración..."

# Verificar que se modificaron las variables
if [ "$DOMAIN" = "vault.tudominio.com" ]; then
    error_exit "Debes modificar la variable DOMAIN en el script"
fi

if [ "$EMAIL" = "tu@email.com" ]; then
    error_exit "Debes modificar la variable EMAIL en el script"
fi

# Verificar que el DNS está configurado
log "Verificando DNS para $DOMAIN..."
RESOLVED_IP=$(dig +short $DOMAIN | tail -n1)
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

if [ -z "$RESOLVED_IP" ]; then
    log "ADVERTENCIA: No se pudo resolver $DOMAIN"
    log "Asegúrate de haber configurado el registro A en Route 53"
    log "Continuando de todas formas..."
else
    log "DNS resuelve a: $RESOLVED_IP"
    log "IP pública de esta instancia: $PUBLIC_IP"
    
    if [ "$RESOLVED_IP" != "$PUBLIC_IP" ]; then
        log "ADVERTENCIA: El DNS no apunta a esta instancia"
        log "Esto puede causar que Let's Encrypt falle"
        log "Continuando de todas formas..."
    else
        log "✓ DNS configurado correctamente"
    fi
fi

################################################################################
# PASO 1: Actualizar el sistema
################################################################################
log "Paso 1: Actualizando paquetes del sistema..."

yum update -y || error_exit "Falló la actualización del sistema"

log "✓ Sistema actualizado correctamente"

################################################################################
# PASO 2: Instalar Docker
################################################################################
log "Paso 2: Instalando Docker..."

# Detectar la versión de Amazon Linux
if grep -q "Amazon Linux 2023" /etc/os-release; then
    log "Detectado: Amazon Linux 2023"
    yum install -y docker || error_exit "Falló la instalación de Docker"
elif grep -q "Amazon Linux 2" /etc/os-release; then
    log "Detectado: Amazon Linux 2"
    amazon-linux-extras install docker -y || error_exit "Falló la instalación de Docker"
else
    log "ADVERTENCIA: Sistema operativo no reconocido, intentando instalación genérica..."
    yum install -y docker || error_exit "Falló la instalación de Docker"
fi

log "✓ Docker instalado correctamente"

################################################################################
# PASO 3: Iniciar y habilitar Docker
################################################################################
log "Paso 3: Configurando servicio Docker..."

systemctl start docker || error_exit "Falló al iniciar Docker"
systemctl enable docker || error_exit "Falló al habilitar Docker"
systemctl is-active --quiet docker || error_exit "Docker no está corriendo"

log "✓ Servicio Docker iniciado y habilitado"

################################################################################
# PASO 4: Crear directorio de datos
################################################################################
log "Paso 4: Creando directorio de datos..."

mkdir -p /vw-data || error_exit "Falló la creación del directorio de datos"
chmod 755 /vw-data

log "✓ Directorio de datos creado: /vw-data"

################################################################################
# PASO 5: Lanzar Vaultwarden
################################################################################
log "Paso 5: Lanzando contenedor de Vaultwarden..."

# Verificar si ya existe un contenedor
if docker ps -a | grep -q vaultwarden; then
    log "Contenedor existente detectado, eliminando..."
    docker stop vaultwarden 2>/dev/null || true
    docker rm vaultwarden 2>/dev/null || true
fi

# Lanzar Vaultwarden solo en localhost (Caddy manejará las conexiones externas)
docker run -d \
  --name vaultwarden \
  -p 127.0.0.1:8080:80 \
  -v /vw-data/:/data/ \
  --restart unless-stopped \
  vaultwarden/server:latest || error_exit "Falló el lanzamiento del contenedor"

log "✓ Contenedor de Vaultwarden lanzado en localhost:8080"

################################################################################
# PASO 6: Instalar Caddy
################################################################################
log "Paso 6: Instalando Caddy..."

# Instalar repositorio de Caddy
yum install -y yum-plugin-copr || error_exit "Falló la instalación de yum-plugin-copr"
yum copr enable @caddy/caddy -y || error_exit "Falló habilitar repositorio de Caddy"
yum install -y caddy || error_exit "Falló la instalación de Caddy"

log "✓ Caddy instalado correctamente"

################################################################################
# PASO 7: Configurar Caddy
################################################################################
log "Paso 7: Configurando Caddy para HTTPS..."

# Crear configuración de Caddy
cat > /etc/caddy/Caddyfile <<EOF
# Configuración de Vaultwarden con HTTPS automático
$DOMAIN {
    # Reverse proxy a Vaultwarden
    reverse_proxy localhost:8080
    
    # Compresión gzip
    encode gzip
    
    # Headers de seguridad
    header {
        # HSTS - Forzar HTTPS
        Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
        
        # Prevenir MIME sniffing
        X-Content-Type-Options "nosniff"
        
        # Prevenir clickjacking
        X-Frame-Options "DENY"
        
        # Política de referrer
        Referrer-Policy "same-origin"
        
        # Eliminar header de servidor
        -Server
    }
    
    # Logging
    log {
        output file /var/log/caddy/access.log
        format json
    }
}

# Redirigir HTTP a HTTPS
http://$DOMAIN {
    redir https://{host}{uri} permanent
}
EOF

# Crear directorio de logs
mkdir -p /var/log/caddy
chown caddy:caddy /var/log/caddy

log "✓ Caddy configurado para $DOMAIN"

################################################################################
# PASO 8: Iniciar Caddy
################################################################################
log "Paso 8: Iniciando Caddy..."

systemctl enable caddy || error_exit "Falló al habilitar Caddy"
systemctl start caddy || error_exit "Falló al iniciar Caddy"

# Esperar a que Caddy inicie
sleep 3

systemctl is-active --quiet caddy || error_exit "Caddy no está corriendo"

log "✓ Caddy iniciado correctamente"

################################################################################
# PASO 9: Verificar instalación
################################################################################
log "Paso 9: Verificando instalación..."

# Verificar que Vaultwarden está corriendo
if docker ps | grep -q vaultwarden; then
    log "✓ Vaultwarden está corriendo"
else
    error_exit "Vaultwarden no está corriendo"
fi

# Verificar que Caddy está corriendo
if systemctl is-active --quiet caddy; then
    log "✓ Caddy está corriendo"
else
    error_exit "Caddy no está corriendo"
fi

# Verificar que el puerto 443 está escuchando
sleep 2
if netstat -tlnp | grep -q ':443'; then
    log "✓ Puerto 443 (HTTPS) está escuchando"
else
    log "ADVERTENCIA: El puerto 443 no parece estar escuchando"
fi

################################################################################
# PASO 10: Información final
################################################################################
log "=========================================="
log "Instalación completada exitosamente!"
log "=========================================="
log ""
log "Información de acceso:"
log "  URL: https://$DOMAIN"
log "  Contenedor: vaultwarden"
log "  Datos: /vw-data/"
log "  Reverse Proxy: Caddy"
log ""
log "Comandos útiles:"
log "  Ver logs de Vaultwarden: docker logs vaultwarden"
log "  Ver logs de Caddy: sudo journalctl -u caddy -f"
log "  Estado de Caddy: sudo systemctl status caddy"
log "  Reiniciar Caddy: sudo systemctl restart caddy"
log ""
log "Notas importantes:"
log "  - Caddy obtendrá el certificado SSL automáticamente"
log "  - Puede tardar 1-2 minutos en obtener el certificado"
log "  - Los certificados se renuevan automáticamente"
log "  - Si hay errores, revisa: sudo journalctl -u caddy"
log ""
log "¡Vaultwarden con HTTPS está listo para usar!"
log "=========================================="

# Crear archivo de estado
echo "Instalación completada: $(date)" > /var/lib/cloud/instance/vaultwarden-https-installed
echo "Dominio: $DOMAIN" >> /var/lib/cloud/instance/vaultwarden-https-installed

log "Archivo de estado creado"

################################################################################
# FIN DEL SCRIPT
################################################################################

exit 0
