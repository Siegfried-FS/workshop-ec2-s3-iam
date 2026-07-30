# 📋 Referencia Rápida de Comandos - Fase 1

Esta es una referencia rápida de todos los comandos usados en la Fase 1. Úsala para copiar y pegar rápidamente durante el workshop.

---

## 🔌 Conexión SSH

### Cambiar Permisos del Archivo de Clave (Mac/Linux)
```bash
chmod 400 vaultwarden-key.pem
```

### Conectarse a la Instancia EC2
```bash
ssh -i /ruta/a/vaultwarden-key.pem ec2-user@TU_IP_PUBLICA
```

**Ejemplo:**
```bash
ssh -i ~/.ssh/vaultwarden-key.pem ec2-user@54.123.45.67
```

---

## 🐳 Instalación de Docker

### 1. Actualizar el Sistema
```bash
sudo yum update -y
```

### 2. Instalar Docker
```bash
sudo amazon-linux-extras install docker -y
```

### 3. Iniciar Docker
```bash
sudo systemctl start docker
```

### 4. Habilitar Docker para Inicio Automático
```bash
sudo systemctl enable docker
```

### 5. Agregar Usuario al Grupo Docker
```bash
sudo usermod -a -G docker ec2-user
```

### 6. Cerrar Sesión (para aplicar cambios de grupo)
```bash
exit
```

### 7. Verificar Instalación de Docker
```bash
docker --version
```

### 8. Probar Docker
```bash
docker run hello-world
```

---

## 🔐 Despliegue de Vaultwarden

### Lanzar Contenedor de Vaultwarden
```bash
docker run -d \
  --name vaultwarden \
  -e DOMAIN=http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4) \
  -e ROCKET_PORT=80 \
  -p 80:80 \
  -v /vw-data/:/data/ \
  --restart unless-stopped \
  vaultwarden/server:latest
```

**Versión en una línea (para copiar fácilmente):**
```bash
docker run -d --name vaultwarden -e DOMAIN=http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4) -e ROCKET_PORT=80 -p 80:80 -v /vw-data/:/data/ --restart unless-stopped vaultwarden/server:latest
```

---

## 🔍 Comandos de Verificación

### Ver Contenedores en Ejecución
```bash
docker ps
```

### Ver Todos los Contenedores (incluyendo detenidos)
```bash
docker ps -a
```

### Ver Logs del Contenedor
```bash
docker logs vaultwarden
```

### Ver Logs en Tiempo Real
```bash
docker logs -f vaultwarden
```

### Verificar Puerto 80
```bash
sudo netstat -tlnp | grep :80
```

### Probar Acceso Local
```bash
curl http://localhost
```

---

## 🔧 Gestión del Contenedor

### Detener el Contenedor
```bash
docker stop vaultwarden
```

### Iniciar el Contenedor
```bash
docker start vaultwarden
```

### Reiniciar el Contenedor
```bash
docker restart vaultwarden
```

### Eliminar el Contenedor (debe estar detenido primero)
```bash
docker rm vaultwarden
```

### Eliminar el Contenedor (forzar, incluso si está corriendo)
```bash
docker rm -f vaultwarden
```

---

## 📊 Comandos de Diagnóstico

### Ver Información del Sistema
```bash
cat /etc/os-release
```

### Ver Uso de Disco
```bash
df -h
```

### Ver Uso de Memoria
```bash
free -h
```

### Ver Procesos en Ejecución
```bash
top
```
(Presiona `q` para salir)

### Ver Información de la Instancia EC2
```bash
curl http://169.254.169.254/latest/meta-data/public-ipv4
```

### Ver Imágenes Docker Descargadas
```bash
docker images
```

### Ver Uso de Espacio de Docker
```bash
docker system df
```

---

## 🧹 Limpieza Local (en el servidor)

### Detener y Eliminar el Contenedor
```bash
docker stop vaultwarden && docker rm vaultwarden
```

### Eliminar la Imagen de Vaultwarden
```bash
docker rmi vaultwarden/server:latest
```

### Eliminar Datos de Vaultwarden (¡CUIDADO! Esto borra tus contraseñas)
```bash
sudo rm -rf /vw-data/
```

### Limpiar Recursos Docker No Usados
```bash
docker system prune -a
```

---

## 🔄 Comandos de Actualización

### Actualizar Vaultwarden a la Última Versión

1. Detener el contenedor actual:
```bash
docker stop vaultwarden
```

2. Eliminar el contenedor:
```bash
docker rm vaultwarden
```

3. Descargar la última imagen:
```bash
docker pull vaultwarden/server:latest
```

4. Lanzar el nuevo contenedor:
```bash
docker run -d --name vaultwarden -p 80:80 -v /vw-data/:/data/ --restart unless-stopped vaultwarden/server:latest
```

---

## 🔐 Comandos de Seguridad

### Ver Reglas del Firewall (iptables)
```bash
sudo iptables -L
```

### Ver Conexiones Activas
```bash
sudo netstat -tuln
```

### Ver Intentos de Conexión SSH
```bash
sudo tail -f /var/log/secure
```

---

## 📦 Backup y Restauración

### Crear Backup de Datos de Vaultwarden
```bash
sudo tar -czf vaultwarden-backup-$(date +%Y%m%d).tar.gz /vw-data/
```

### Copiar Backup a tu Máquina Local (desde tu computadora)
```bash
scp -i ~/.ssh/vaultwarden-key.pem ec2-user@TU_IP:/home/ec2-user/vaultwarden-backup-*.tar.gz ~/Downloads/
```

### Restaurar desde Backup
```bash
sudo tar -xzf vaultwarden-backup-YYYYMMDD.tar.gz -C /
```

---

## 🚪 Salir de la Sesión SSH

```bash
exit
```

O presiona `Ctrl + D`

---

## 💡 Comandos Útiles Adicionales

### Ver Información del Contenedor
```bash
docker inspect vaultwarden
```

### Ejecutar Comando Dentro del Contenedor
```bash
docker exec -it vaultwarden /bin/sh
```

### Ver Variables de Entorno del Contenedor
```bash
docker exec vaultwarden env
```

### Ver Estadísticas de Uso del Contenedor
```bash
docker stats vaultwarden
```

---

## 🔗 Secuencia Completa (Copy-Paste)

Si quieres ejecutar todo de una vez (después de conectarte por SSH):

```bash
# Actualizar sistema
sudo yum update -y

# Instalar Docker
sudo amazon-linux-extras install docker -y

# Iniciar y habilitar Docker
sudo systemctl start docker
sudo systemctl enable docker

# Agregar usuario al grupo docker
sudo usermod -a -G docker ec2-user

# Cerrar sesión para aplicar cambios
exit

# Después de reconectarte:
# Lanzar Vaultwarden
docker run -d --name vaultwarden -p 80:80 -v /vw-data/:/data/ --restart unless-stopped vaultwarden/server:latest

# Verificar
docker ps
```

---

## 📝 Notas

- Reemplaza `TU_IP_PUBLICA` con la IP pública real de tu instancia
- Reemplaza `/ruta/a/vaultwarden-key.pem` con la ruta real de tu archivo de clave
- Los comandos con `sudo` requieren permisos de administrador
- Algunos comandos pueden tardar varios minutos en completarse

---

**¿Necesitas más ayuda?** Consulta el [README completo de la Fase 1](README.md)
