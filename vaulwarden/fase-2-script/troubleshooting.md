# 🔧 Solución de Problemas - Fase 2

Esta guía te ayudará a diagnosticar y resolver los problemas más comunes al usar el script de automatización.

---

## 📋 Tabla de Contenidos

1. [La instancia no responde](#1-la-instancia-no-responde)
2. [Docker no se instaló](#2-docker-no-se-instaló)
3. [El contenedor no está corriendo](#3-el-contenedor-no-está-corriendo)
4. [No puedo acceder a Vaultwarden](#4-no-puedo-acceder-a-vaultwarden)
5. [El script no se ejecutó](#5-el-script-no-se-ejecutó)
6. [Errores en los logs](#6-errores-en-los-logs)
7. [Cómo revisar logs del User Data](#7-cómo-revisar-logs-del-user-data)

---

## 1. La Instancia No Responde

### Síntomas
- No puedes conectarte por SSH
- La página web no carga
- La instancia parece "congelada"

### Diagnóstico

#### Paso 1: Verificar el Estado de la Instancia

1. Ve a la consola de EC2
2. Selecciona tu instancia
3. Verifica:
   - **Instance state**: Debe ser `Running`
   - **Status check**: Debe ser `2/2 checks passed`

#### Paso 2: Verificar Security Group

1. En los detalles de la instancia, ve a la pestaña **"Security"**
2. Haz clic en el Security Group
3. Verifica las reglas de entrada:
   - Puerto 22 (SSH) debe estar abierto
   - Puerto 80 (HTTP) debe estar abierto

### Soluciones

#### Solución 1: Esperar Más Tiempo

El script puede tardar 5-7 minutos en completarse. Espera un poco más.

#### Solución 2: Verificar Security Group

Si el Security Group no tiene las reglas correctas:

1. Ve a EC2 → Security Groups
2. Selecciona tu Security Group
3. Haz clic en **"Edit inbound rules"**
4. Agrega las reglas faltantes:
   - SSH (22) desde tu IP
   - HTTP (80) desde 0.0.0.0/0

#### Solución 3: Reiniciar la Instancia

1. Selecciona la instancia
2. **Instance state** → **Reboot instance**
3. Espera 2-3 minutos

#### Solución 4: Verificar la Clave SSH

```bash
# Verifica los permisos
chmod 400 ~/.ssh/vaultwarden-key.pem

# Intenta conectarte con verbose para ver el error
ssh -v -i ~/.ssh/vaultwarden-key.pem ec2-user@TU_IP
```

---

## 2. Docker No Se Instaló

### Síntomas
- Al conectarte por SSH y ejecutar `docker --version`, obtienes: `command not found`
- Los logs muestran errores de instalación de Docker

### Diagnóstico

#### Conectarse y Verificar

```bash
# Conectarse por SSH
ssh -i ~/.ssh/vaultwarden-key.pem ec2-user@TU_IP

# Verificar si Docker está instalado
docker --version

# Verificar el sistema operativo
cat /etc/os-release
```

### Soluciones

#### Solución 1: Verificar la AMI

El script está diseñado para **Amazon Linux 2 y Amazon Linux 2023**. 

**Para Amazon Linux 2023:**
```bash
# Instalar Docker directamente
sudo yum install -y docker
```

**Para Amazon Linux 2:**
```bash
# Instalar Docker con amazon-linux-extras
sudo amazon-linux-extras install docker -y
```

El script detecta automáticamente la versión y usa el método correcto.

#### Solución 2: Revisar los Logs

```bash
# Ver el log de instalación
sudo cat /var/log/vaultwarden-install.log

# Ver logs de cloud-init
sudo cat /var/log/cloud-init-output.log

# Buscar errores específicos
sudo grep -i error /var/log/vaultwarden-install.log
```

#### Solución 3: Instalar Docker Manualmente

Si el script falló, instala Docker manualmente:

```bash
# Actualizar sistema
sudo yum update -y

# Instalar Docker
sudo amazon-linux-extras install docker -y

# Iniciar Docker
sudo systemctl start docker
sudo systemctl enable docker

# Verificar
docker --version
```

#### Solución 4: Ejecutar el Script Manualmente

```bash
# El script de User Data se guarda aquí
sudo bash /var/lib/cloud/instance/user-data.txt
```

---

## 3. El Contenedor No Está Corriendo

### Síntomas
- `docker ps` no muestra el contenedor de Vaultwarden
- La página web no carga aunque Docker esté instalado

### Diagnóstico

#### Verificar Contenedores

```bash
# Ver contenedores corriendo
docker ps

# Ver todos los contenedores (incluyendo detenidos)
docker ps -a

# Ver logs del contenedor
docker logs vaultwarden
```

### Soluciones

#### Solución 1: El Contenedor Se Detuvo

Si ves el contenedor en `docker ps -a` pero con estado `Exited`:

```bash
# Ver por qué se detuvo
docker logs vaultwarden

# Intentar iniciarlo
docker start vaultwarden

# Si no funciona, recrearlo
docker rm vaultwarden
docker run -d --name vaultwarden -p 80:80 -v /vw-data/:/data/ --restart unless-stopped vaultwarden/server:latest
```

#### Solución 2: El Puerto 80 Está en Uso

```bash
# Verificar qué está usando el puerto 80
sudo netstat -tlnp | grep :80

# Si algo más está usando el puerto, detenerlo o usar otro puerto
docker run -d --name vaultwarden -p 8080:80 -v /vw-data/:/data/ --restart unless-stopped vaultwarden/server:latest
```

Luego accede a `http://TU_IP:8080`

#### Solución 3: Problema con el Volumen

```bash
# Verificar que el directorio existe
ls -la /vw-data/

# Si no existe, crearlo
sudo mkdir -p /vw-data
sudo chmod 755 /vw-data

# Relanzar el contenedor
docker rm -f vaultwarden
docker run -d --name vaultwarden -p 80:80 -v /vw-data/:/data/ --restart unless-stopped vaultwarden/server:latest
```

#### Solución 4: Problema con la Imagen

```bash
# Eliminar la imagen corrupta
docker rmi vaultwarden/server:latest

# Descargar nuevamente
docker pull vaultwarden/server:latest

# Lanzar el contenedor
docker run -d --name vaultwarden -p 80:80 -v /vw-data/:/data/ --restart unless-stopped vaultwarden/server:latest
```

---

## 4. No Puedo Acceder a Vaultwarden

### Síntomas
- El navegador muestra "This site can't be reached"
- "Connection refused" o "Connection timed out"
- El contenedor está corriendo pero la página no carga

### Diagnóstico

#### Verificar Desde el Servidor

```bash
# Conectarse por SSH
ssh -i ~/.ssh/vaultwarden-key.pem ec2-user@TU_IP

# Probar acceso local
curl http://localhost

# Verificar que el puerto está escuchando
sudo netstat -tlnp | grep :80

# Ver logs del contenedor
docker logs vaultwarden
```

### Soluciones

#### Solución 1: Verificar Security Group

El problema más común es el Security Group:

1. Ve a EC2 → Security Groups
2. Selecciona tu Security Group
3. Verifica que existe esta regla:
   - **Type**: HTTP
   - **Port**: 80
   - **Source**: 0.0.0.0/0

Si no existe, agrégala:
1. **Edit inbound rules**
2. **Add rule**
3. Type: HTTP, Source: Anywhere-IPv4
4. **Save rules**

#### Solución 2: Verificar la IP

Asegúrate de usar la **IP pública** (no la privada):

```bash
# Obtener la IP pública desde el servidor
curl http://169.254.169.254/latest/meta-data/public-ipv4
```

O desde la consola de EC2:
- Selecciona la instancia
- Copia **Public IPv4 address**

#### Solución 3: Usar HTTP (no HTTPS)

Asegúrate de usar `http://` en la URL:

❌ Incorrecto: `https://54.123.45.67`  
✅ Correcto: `http://54.123.45.67`

#### Solución 4: Verificar el Firewall Local

```bash
# Ver reglas de iptables
sudo iptables -L

# Si hay reglas bloqueando, limpiarlas (temporal)
sudo iptables -F
```

#### Solución 5: Reiniciar el Contenedor

```bash
docker restart vaultwarden

# Esperar 10 segundos
sleep 10

# Verificar
curl http://localhost
```

---

## 5. El Script No Se Ejecutó

### Síntomas
- No existe el archivo `/var/log/vaultwarden-install.log`
- Docker no está instalado
- Nada parece haber cambiado en la instancia

### Diagnóstico

#### Verificar User Data

```bash
# Ver el User Data que se configuró
sudo cat /var/lib/cloud/instance/user-data.txt
```

### Soluciones

#### Solución 1: Verificar que Pegaste el Script

1. Termina esta instancia
2. Lanza una nueva
3. En **Advanced details** → **User data**:
   - Asegúrate de pegar el script completo
   - Debe empezar con `#!/bin/bash`
   - No agregues comillas ni modifiques el formato

#### Solución 2: Verificar Logs de Cloud-Init

```bash
# Ver logs de cloud-init
sudo cat /var/log/cloud-init-output.log

# Buscar errores
sudo grep -i error /var/log/cloud-init-output.log
```

#### Solución 3: Ejecutar el Script Manualmente

```bash
# Ejecutar el User Data manualmente
sudo bash /var/lib/cloud/instance/user-data.txt

# Ver la salida en tiempo real
sudo bash -x /var/lib/cloud/instance/user-data.txt
```

#### Solución 4: Verificar Permisos

```bash
# Verificar que cloud-init tiene permisos
sudo systemctl status cloud-init

# Reiniciar cloud-init
sudo systemctl restart cloud-init
```

---

## 6. Errores en los Logs

### Errores Comunes y Soluciones

#### Error: "Package docker not found"

**Causa**: AMI incorrecta o repositorios no actualizados

**Solución**:
```bash
# Actualizar repositorios
sudo yum update -y

# Intentar instalar Docker
sudo amazon-linux-extras install docker -y
```

#### Error: "Cannot connect to the Docker daemon"

**Causa**: Docker no está corriendo

**Solución**:
```bash
# Iniciar Docker
sudo systemctl start docker

# Verificar estado
sudo systemctl status docker
```

#### Error: "port is already allocated"

**Causa**: El puerto 80 ya está en uso

**Solución**:
```bash
# Ver qué está usando el puerto
sudo netstat -tlnp | grep :80

# Detener el proceso o usar otro puerto
docker run -d --name vaultwarden -p 8080:80 ...
```

#### Error: "No space left on device"

**Causa**: Disco lleno

**Solución**:
```bash
# Ver uso de disco
df -h

# Limpiar Docker
docker system prune -a

# Si es necesario, aumentar el tamaño del volumen EBS
```

#### Error: "Permission denied"

**Causa**: Permisos insuficientes

**Solución**:
```bash
# Agregar usuario al grupo docker
sudo usermod -a -G docker ec2-user

# Cerrar sesión y volver a conectar
exit
```

---

## 7. Cómo Revisar Logs del User Data

### Ubicaciones de Logs

```bash
# Log principal de nuestro script
sudo cat /var/log/vaultwarden-install.log

# Logs de cloud-init (incluye User Data)
sudo cat /var/log/cloud-init.log
sudo cat /var/log/cloud-init-output.log

# Logs del sistema
sudo journalctl -u cloud-init

# Logs de Docker
sudo journalctl -u docker
```

### Ver Logs en Tiempo Real

```bash
# Ver el log de instalación en tiempo real
sudo tail -f /var/log/vaultwarden-install.log

# Ver logs de cloud-init en tiempo real
sudo tail -f /var/log/cloud-init-output.log
```

### Buscar Errores Específicos

```bash
# Buscar errores en el log de instalación
sudo grep -i error /var/log/vaultwarden-install.log

# Buscar fallos
sudo grep -i fail /var/log/vaultwarden-install.log

# Ver las últimas 50 líneas
sudo tail -n 50 /var/log/vaultwarden-install.log
```

### Verificar que el Script Completó

```bash
# Buscar el mensaje de éxito
sudo grep "Instalación completada exitosamente" /var/log/vaultwarden-install.log

# Verificar el archivo de estado
cat /var/lib/cloud/instance/vaultwarden-installed
```

---

## 🔍 Comandos de Diagnóstico Útiles

### Estado del Sistema

```bash
# Ver información del sistema
uname -a
cat /etc/os-release

# Ver uso de recursos
top
htop  # si está instalado
free -h
df -h
```

### Estado de Docker

```bash
# Versión de Docker
docker --version

# Información de Docker
docker info

# Contenedores
docker ps -a

# Imágenes
docker images

# Uso de espacio
docker system df

# Logs de un contenedor
docker logs vaultwarden
docker logs -f vaultwarden  # tiempo real
```

### Estado de Red

```bash
# Puertos escuchando
sudo netstat -tlnp

# Conexiones activas
sudo netstat -an

# Verificar conectividad
ping -c 4 google.com

# Obtener IP pública
curl http://169.254.169.254/latest/meta-data/public-ipv4
```

### Estado de Servicios

```bash
# Estado de Docker
sudo systemctl status docker

# Estado de cloud-init
sudo systemctl status cloud-init

# Ver todos los servicios
sudo systemctl list-units --type=service
```

---

## 🆘 Último Recurso: Empezar de Nuevo

Si nada funciona, a veces es más rápido empezar de nuevo:

### Pasos

1. **Terminar la instancia actual**:
   - EC2 → Instances
   - Selecciona la instancia
   - Instance state → Terminate instance

2. **Lanzar una nueva instancia**:
   - Usa **Amazon Linux 2 AMI (HVM)**
   - Tipo: **t2.micro**
   - Security Group con puertos 22, 80, 443
   - Pega el script en **User Data**

3. **Esperar 5-7 minutos**

4. **Verificar**:
   ```bash
   ssh -i ~/.ssh/vaultwarden-key.pem ec2-user@NUEVA_IP
   sudo cat /var/log/vaultwarden-install.log
   docker ps
   ```

---

## 📞 Obtener Ayuda Adicional

### Recursos

- [Documentación de AWS EC2](https://docs.aws.amazon.com/ec2/)
- [Documentación de Docker](https://docs.docker.com/)
- [Vaultwarden Wiki](https://github.com/dani-garcia/vaultwarden/wiki)
- [AWS Support](https://console.aws.amazon.com/support/)

### Reportar Problemas

Si encuentras un problema con el script o la documentación:

1. Abre un Issue en el repositorio
2. Incluye:
   - Descripción del problema
   - Logs relevantes
   - Pasos para reproducir
   - AMI y región usada

---

## ✅ Checklist de Verificación

Usa esta checklist para diagnosticar problemas:

```
□ La instancia está en estado "Running"
□ Status checks muestra "2/2 checks passed"
□ Security Group tiene puerto 22 abierto (SSH)
□ Security Group tiene puerto 80 abierto (HTTP)
□ Puedo conectarme por SSH
□ El archivo /var/log/vaultwarden-install.log existe
□ El log muestra "Instalación completada exitosamente"
□ Docker está instalado (docker --version funciona)
□ Docker está corriendo (systemctl status docker)
□ El contenedor está corriendo (docker ps muestra vaultwarden)
□ El puerto 80 está escuchando (netstat -tlnp | grep :80)
□ curl http://localhost devuelve HTML
□ Estoy usando la IP pública correcta
□ Estoy usando http:// (no https://)
```

Si todos los checks pasan y aún no funciona, revisa la sección de [Último Recurso](#-último-recurso-empezar-de-nuevo).

---

**¿Resolviste tu problema?** ¡Genial! Vuelve al [README de la Fase 2](README.md)

**¿Aún tienes problemas?** Abre un Issue en el repositorio con los detalles.