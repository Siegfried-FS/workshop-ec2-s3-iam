# 🖥️ Guía de Lanzamiento desde CLI

Esta guía te enseña cómo lanzar una instancia EC2 con Vaultwarden usando AWS CLI en lugar de la consola web.

## 📋 Prerequisitos

### 1. AWS CLI Instalado

Verifica si lo tienes:
```bash
aws --version
```

Si no lo tienes, instálalo:
- **macOS**: `brew install awscli`
- **Linux**: `pip install awscli`
- **Windows**: [Descargar instalador](https://aws.amazon.com/cli/)

### 2. AWS CLI Configurado

Configura tus credenciales:
```bash
aws configure
```

Te pedirá:
- **AWS Access Key ID**: Tu access key
- **AWS Secret Access Key**: Tu secret key
- **Default region**: `us-east-1` (o tu región preferida)
- **Default output format**: `json`

**¿Cómo obtener las credenciales?**
1. Ve a [IAM Console](https://console.aws.amazon.com/iam/)
2. Click en tu usuario
3. Tab "Security credentials"
4. "Create access key"

### 3. Par de Claves SSH

Crea un par de claves si no tienes uno:

```bash
# Crear par de claves
aws ec2 create-key-pair \
  --key-name vaultwarden-key \
  --query 'KeyMaterial' \
  --output text > ~/.ssh/vaultwarden-key.pem

# Dar permisos correctos
chmod 400 ~/.ssh/vaultwarden-key.pem
```

## 🚀 Uso Rápido

### Opción 1: Instalación HTTP (Simple)

```bash
# 1. Editar el script
nano launch-ec2-cli.sh

# Cambiar estas líneas:
KEY_NAME="vaultwarden-key"  # Tu par de claves
REGION="us-east-1"          # Tu región
INSTALL_TYPE="http"         # Dejar en http

# 2. Dar permisos de ejecución
chmod +x launch-ec2-cli.sh

# 3. Ejecutar
./launch-ec2-cli.sh
```

### Opción 2: Instalación HTTPS (Con Dominio)

```bash
# 1. Editar el script
nano launch-ec2-cli.sh

# Cambiar estas líneas:
KEY_NAME="vaultwarden-key"
REGION="us-east-1"
INSTALL_TYPE="https"                    # Cambiar a https
DOMAIN="vault.tudominio.com"            # Tu dominio
EMAIL="tu@email.com"                    # Tu email
SMTP_HOST="smtp.gmail.com"              # Servidor SMTP
SMTP_USERNAME="tu@gmail.com"            # Tu correo
SMTP_PASSWORD="tu-contraseña-de-app"   # Contraseña de aplicación

# 2. Dar permisos de ejecución
chmod +x launch-ec2-cli.sh

# 3. Ejecutar
./launch-ec2-cli.sh
```

## 📝 Configuración Detallada

### Variables Principales

```bash
# Par de claves SSH (debe existir en AWS)
KEY_NAME="vaultwarden-key"

# Región de AWS
REGION="us-east-1"

# Tipo de instancia (t2.micro es Free Tier)
INSTANCE_TYPE="t2.micro"

# AMI de Amazon Linux 2023
# Encuentra la más reciente con:
# aws ec2 describe-images --owners amazon \
#   --filters "Name=name,Values=al2023-ami-*" \
#   --query 'Images[0].ImageId'
AMI_ID="ami-0c02fb55b34f3b1f2"

# Nombre de la instancia
INSTANCE_NAME="Vaultwarden-CLI"

# Tipo de instalación
INSTALL_TYPE="http"  # o "https"
```

### Variables HTTPS (Solo si INSTALL_TYPE="https")

```bash
DOMAIN="vault.tudominio.com"
EMAIL="tu@email.com"
SMTP_HOST="smtp.gmail.com"
SMTP_USERNAME="tu@gmail.com"
SMTP_PASSWORD="tu-contraseña-de-app"
```

## 🔍 Verificación

### Ver el Progreso

```bash
# Conectar por SSH
ssh -i ~/.ssh/vaultwarden-key.pem ec2-user@IP_PUBLICA

# Ver logs de instalación
cat /var/log/vaultwarden-install.log

# Ver logs en tiempo real
tail -f /var/log/vaultwarden-install.log
```

### Verificar que Vaultwarden Está Corriendo

```bash
# Conectar por SSH
ssh -i ~/.ssh/vaultwarden-key.pem ec2-user@IP_PUBLICA

# Ver contenedores
docker ps

# Ver logs de Vaultwarden
docker logs vaultwarden
```

## 🧹 Limpieza de Recursos

El script guarda la información de la instancia en un archivo `ec2-instance-info-*.txt`. Usa los comandos de ese archivo para limpiar:

```bash
# 1. Terminar la instancia
aws ec2 terminate-instances --instance-ids i-1234567890abcdef0 --region us-east-1

# 2. Esperar a que termine
aws ec2 wait instance-terminated --instance-ids i-1234567890abcdef0 --region us-east-1

# 3. Eliminar Security Group
aws ec2 delete-security-group --group-id sg-1234567890abcdef0 --region us-east-1
```

## 📊 Comandos Útiles de AWS CLI

### Listar Instancias

```bash
# Todas las instancias
aws ec2 describe-instances --region us-east-1

# Solo instancias corriendo
aws ec2 describe-instances \
  --filters "Name=instance-state-name,Values=running" \
  --region us-east-1

# Formato tabla
aws ec2 describe-instances \
  --query 'Reservations[*].Instances[*].[InstanceId,State.Name,PublicIpAddress,Tags[?Key==`Name`].Value|[0]]' \
  --output table \
  --region us-east-1
```

### Gestionar Instancia

```bash
# Ver detalles de una instancia
aws ec2 describe-instances \
  --instance-ids i-1234567890abcdef0 \
  --region us-east-1

# Detener instancia
aws ec2 stop-instances \
  --instance-ids i-1234567890abcdef0 \
  --region us-east-1

# Iniciar instancia
aws ec2 start-instances \
  --instance-ids i-1234567890abcdef0 \
  --region us-east-1

# Reiniciar instancia
aws ec2 reboot-instances \
  --instance-ids i-1234567890abcdef0 \
  --region us-east-1

# Terminar instancia
aws ec2 terminate-instances \
  --instance-ids i-1234567890abcdef0 \
  --region us-east-1
```

### Gestionar Security Groups

```bash
# Listar Security Groups
aws ec2 describe-security-groups --region us-east-1

# Ver reglas de un Security Group
aws ec2 describe-security-groups \
  --group-ids sg-1234567890abcdef0 \
  --region us-east-1

# Eliminar Security Group
aws ec2 delete-security-group \
  --group-id sg-1234567890abcdef0 \
  --region us-east-1
```

### Gestionar Pares de Claves

```bash
# Listar pares de claves
aws ec2 describe-key-pairs --region us-east-1

# Crear par de claves
aws ec2 create-key-pair \
  --key-name mi-clave \
  --query 'KeyMaterial' \
  --output text > ~/.ssh/mi-clave.pem

# Eliminar par de claves
aws ec2 delete-key-pair \
  --key-name mi-clave \
  --region us-east-1
```

## 🔧 Solución de Problemas

### Error: "AWS CLI not configured"

```bash
# Configurar AWS CLI
aws configure

# Verificar configuración
aws sts get-caller-identity
```

### Error: "Key pair does not exist"

```bash
# Listar pares de claves disponibles
aws ec2 describe-key-pairs --region us-east-1

# Crear uno nuevo
aws ec2 create-key-pair \
  --key-name vaultwarden-key \
  --query 'KeyMaterial' \
  --output text > ~/.ssh/vaultwarden-key.pem

chmod 400 ~/.ssh/vaultwarden-key.pem
```

### Error: "Invalid AMI ID"

La AMI puede variar por región. Encuentra la correcta:

```bash
# Amazon Linux 2023
aws ec2 describe-images \
  --owners amazon \
  --filters "Name=name,Values=al2023-ami-*" \
  --query 'Images[0].ImageId' \
  --output text \
  --region us-east-1

# Amazon Linux 2
aws ec2 describe-images \
  --owners amazon \
  --filters "Name=name,Values=amzn2-ami-hvm-*" \
  --query 'Images[0].ImageId' \
  --output text \
  --region us-east-1
```

### Error: "Permission denied" al conectar por SSH

```bash
# Verificar permisos del archivo .pem
ls -l ~/.ssh/vaultwarden-key.pem

# Debe mostrar: -r-------- (400)
# Si no, corregir:
chmod 400 ~/.ssh/vaultwarden-key.pem
```

### La instancia se lanzó pero Vaultwarden no funciona

```bash
# Conectar por SSH
ssh -i ~/.ssh/vaultwarden-key.pem ec2-user@IP_PUBLICA

# Ver logs de instalación
cat /var/log/vaultwarden-install.log

# Buscar errores
grep ERROR /var/log/vaultwarden-install.log

# Ver logs de cloud-init
sudo cat /var/log/cloud-init-output.log
```

## 💡 Tips y Mejores Prácticas

### 1. Usar Variables de Entorno

```bash
# Definir variables
export AWS_REGION="us-east-1"
export KEY_NAME="vaultwarden-key"

# Usar en comandos
aws ec2 describe-instances --region $AWS_REGION
```

### 2. Crear Alias

Agrega a tu `~/.bashrc` o `~/.zshrc`:

```bash
alias ec2-list='aws ec2 describe-instances --query "Reservations[*].Instances[*].[InstanceId,State.Name,PublicIpAddress,Tags[?Key==\`Name\`].Value|[0]]" --output table'
alias ec2-running='aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query "Reservations[*].Instances[*].[InstanceId,PublicIpAddress,Tags[?Key==\`Name\`].Value|[0]]" --output table'
```

### 3. Usar Perfiles de AWS

Si tienes múltiples cuentas:

```bash
# Configurar perfil
aws configure --profile trabajo

# Usar perfil
aws ec2 describe-instances --profile trabajo --region us-east-1

# O exportar
export AWS_PROFILE=trabajo
```

### 4. Guardar Comandos Frecuentes

Crea un archivo `aws-commands.sh`:

```bash
#!/bin/bash

# Listar mis instancias
list_instances() {
    aws ec2 describe-instances \
        --filters "Name=instance-state-name,Values=running" \
        --query 'Reservations[*].Instances[*].[InstanceId,PublicIpAddress,Tags[?Key==`Name`].Value|[0]]' \
        --output table
}

# Conectar a instancia
connect() {
    local instance_id=$1
    local ip=$(aws ec2 describe-instances \
        --instance-ids $instance_id \
        --query 'Reservations[0].Instances[0].PublicIpAddress' \
        --output text)
    ssh -i ~/.ssh/vaultwarden-key.pem ec2-user@$ip
}

# Usar: source aws-commands.sh && list_instances
```

## 📚 Recursos Adicionales

- [AWS CLI Command Reference](https://docs.aws.amazon.com/cli/latest/reference/)
- [AWS CLI EC2 Commands](https://docs.aws.amazon.com/cli/latest/reference/ec2/)
- [AWS CLI Configuration](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html)
- [JMESPath Tutorial](https://jmespath.org/tutorial.html) (para queries)

## 🎯 Ventajas de Usar CLI

✅ **Automatización**: Fácil de integrar en scripts  
✅ **Repetibilidad**: Mismo comando = mismo resultado  
✅ **Velocidad**: Más rápido que la consola web  
✅ **Scripting**: Puedes crear flujos complejos  
✅ **CI/CD**: Integrable en pipelines  

---

**¿Preguntas?**
- 💬 Contacto: https://linktr.ee/siegfried.fs
- 🤝 AWS User Group Playa Vicente
- 🐛 GitHub Issues

---

**Creado por Roberto Flores para AWS User Group Playa Vicente**
