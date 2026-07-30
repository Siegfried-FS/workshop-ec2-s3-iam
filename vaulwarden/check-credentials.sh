#!/bin/bash

################################################################################
# Script de Verificación de Credenciales
################################################################################
#
# Este script verifica que no haya credenciales personales en los archivos
# que se van a subir a GitHub.
#
# Uso: ./check-credentials.sh
#
################################################################################

echo "🔍 Verificando archivos que se subirán a GitHub..."
echo ""

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Contador de problemas
ISSUES=0

# Función para verificar un archivo
check_file() {
    local file=$1
    local pattern=$2
    local description=$3
    
    if [ -f "$file" ]; then
        if grep -q "$pattern" "$file" 2>/dev/null; then
            echo -e "${RED}❌ ENCONTRADO:${NC} $description en $file"
            ISSUES=$((ISSUES + 1))
        fi
    fi
}

echo "Verificando datos personales..."
echo ""

# Verificar dominio personal (reemplaza con tu dominio)
check_file "fase-2-script/install-vaultwarden-https.sh" "TU_SUBDOMINIO.TU_DOMINIO.com" "Dominio personal"
check_file "fase-2-script/launch-ec2-cli.sh" "TU_SUBDOMINIO.TU_DOMINIO.com" "Dominio personal"

# Verificar email personal (reemplaza con tus emails)
check_file "fase-2-script/install-vaultwarden-https.sh" "tu-email@tu-dominio.com" "Email personal"
check_file "fase-2-script/install-vaultwarden-https.sh" "tu-email@gmail.com" "Email Gmail"
check_file "fase-2-script/launch-ec2-cli.sh" "tu-nombre" "Nombre personal"

# Verificar contraseñas (reemplaza con tus contraseñas si deseas verificar antes de publicar)
check_file "fase-2-script/install-vaultwarden-https.sh" "TU_APP_PASSWORD_AQUI" "Contraseña de aplicación Gmail"
check_file "fase-2-script/install-vaultwarden-https.sh" "TU_SMTP_PASSWORD_AQUI" "Contraseña SMTP"

echo ""
echo "Verificando que archivos personales están en .gitignore..."
echo ""

# Verificar que el archivo personal existe pero está ignorado
if [ -f "fase-2-script/install-vaultwarden-https-personal.sh" ]; then
    if git rev-parse --git-dir > /dev/null 2>&1; then
        if git check-ignore "fase-2-script/install-vaultwarden-https-personal.sh" &>/dev/null; then
            echo -e "${GREEN}✓${NC} install-vaultwarden-https-personal.sh está en .gitignore"
        else
            echo -e "${RED}❌${NC} install-vaultwarden-https-personal.sh NO está en .gitignore"
            ISSUES=$((ISSUES + 1))
        fi
    else
        if grep -q "\*-personal.sh" .gitignore 2>/dev/null; then
            echo -e "${GREEN}✓${NC} install-vaultwarden-https-personal.sh estará protegido por .gitignore"
        else
            echo -e "${RED}❌${NC} Patrón *-personal.sh NO está en .gitignore"
            ISSUES=$((ISSUES + 1))
        fi
    fi
else
    echo -e "${YELLOW}⚠${NC} install-vaultwarden-https-personal.sh no existe (OK)"
fi

echo ""
echo "Verificando archivos que se subirán..."
echo ""

echo "Archivos que se subirán a GitHub:"
if git rev-parse --git-dir > /dev/null 2>&1; then
    git status --short 2>/dev/null || echo "Error al obtener estado de git"
else
    echo "No es un repositorio git todavía (ejecuta 'git init' primero)"
    echo ""
    echo "Archivos que se protegerán con .gitignore:"
    grep -v "^#" .gitignore | grep -v "^$" | head -10
fi

echo ""
echo "=========================================="
if [ $ISSUES -eq 0 ]; then
    echo -e "${GREEN}✅ TODO BIEN${NC}"
    echo "No se encontraron credenciales personales en archivos públicos"
    echo "Es seguro hacer commit y push"
else
    echo -e "${RED}⚠️  ATENCIÓN: $ISSUES problema(s) encontrado(s)${NC}"
    echo ""
    echo "ANTES de subir a GitHub:"
    echo "1. Revisa los archivos marcados arriba"
    echo "2. Reemplaza datos personales con placeholders"
    echo "3. Ejecuta este script de nuevo"
fi
echo "=========================================="
echo ""

exit $ISSUES
