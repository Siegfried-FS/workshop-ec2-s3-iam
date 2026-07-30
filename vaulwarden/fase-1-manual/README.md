# 🖱️ Fase 1: Despliegue Manual con la Consola de AWS

⏱️ **Tiempo estimado**: 30 minutos  
🎯 **Nivel**: Principiante  
📋 **Prerequisitos**: [Cuenta de AWS y cliente SSH](../prerequisitos.md)

## 📖 Introducción

En esta fase aprenderás a desplegar Vaultwarden en AWS EC2 usando únicamente la consola web de AWS y comandos básicos de SSH. Este método te ayudará a entender cada componente de la infraestructura antes de automatizar.

### ¿Qué aprenderás?

- ✅ Cómo lanzar una instancia EC2
- ✅ Configurar Security Groups (firewall)
- ✅ Conectarte por SSH a un servidor Linux
- ✅ Instalar Docker en Amazon Linux 2
- ✅ Ejecutar contenedores Docker
- ✅ Verificar que Vaultwarden está funcionando

### ¿Qué desplegarás?

Al final de esta fase tendrás:
- Una instancia EC2 t2.micro corriendo Amazon Linux 2
- Docker instalado y configurado
- Vaultwarden accesible desde tu navegador
- Un gestor de contraseñas auto-hospedado funcionando

---

## 📝 Paso 1: Lanzar Instancia EC2 (10 minutos)

### 1.1 Acceder a la Consola de EC2

1. Inicia sesión en [AWS Console](https://console.aws.amazon.com/)
2. En la barra de búsqueda superior, escribe **"EC2"**
3. Haz clic en **"EC2"** (servicio de máquinas virtuales)
4. Asegúrate de estar en la región correcta (arriba a la derecha, ej: **us-east-1**)

### 1.2 Iniciar el Asistente de Lanzamiento

1. Haz clic en el botón naranja **"Launch instance"** (Lanzar instancia)
2. Verás el asistente de configuración

### 1.3 Configurar Nombre y Tags

**Nombre de la instancia:**
```
Vaultwarden-Workshop
```

Esto te ayudará a identificar tu instancia fácilmente.

### 1.4 Seleccionar AMI (Imagen del Sistema Operativo)

En la sección **"Application and OS Images (Amazon Machine Image)"**:

1. Selecciona **"Amazon Linux"**
2. Elige **"Amazon Linux 2 AMI (HVM)"** - Kernel 5.10
3. Arquitectura: **64-bit (x86)**
4. Debe decir **"Free tier eligible"** (elegible para nivel gratuito)

### 1.5 Elegir Tipo de Instancia

En la sección **"Instance type"**:

1. Selecciona **"t2.micro"**
   - 1 vCPU
   - 1 GB RAM
   - ✅ Free tier eligible

### 1.6 Configurar Par de Claves SSH

En la sección **"Key pair (login)"**:

**Si ya tienes un par de claves:**
- Selecciónalo del menú desplegable

**Si es tu primera vez:**
1. Haz clic en **"Create new key pair"**
2. Nombre: `vaultwarden-key`
3. Tipo: **RSA**
4. Formato: 
   - **`.pem`** para Mac/Linux
   - **`.ppk`** para Windows con PuTTY
5. Haz clic en **"Create key pair"**
6. **¡IMPORTANTE!** El archivo se descargará automáticamente. Guárdalo en un lugar seguro.

⚠️ **Advertencia**: No podrás descargar este archivo nuevamente. Si lo pierdes, no podrás conectarte a tu instancia.

### 1.7 Configurar Network Settings (Security Group)

En la sección **"Network settings"**, haz clic en **"Edit"**:

**Configuración básica:**
- VPC: Deja la **VPC por defecto**
- Subnet: **No preference** (sin preferencia)
- Auto-assign public IP: **Enable** (habilitar)

**Firewall (Security groups):**

1. Selecciona **"Create security group"**
2. Nombre: `vaultwarden-sg`
3. Descripción: `Security group for Vaultwarden workshop`

**Reglas de entrada (Inbound rules):**

Necesitas agregar 3 reglas:

**Regla 1: SSH**
- Type: **SSH**
- Protocol: **TCP**
- Port: **22**
- Source: **My IP** (tu IP actual) - Más seguro
  - O **Anywhere (0.0.0.0/0)** si tienes IP dinámica
- Description: `SSH access`

**Regla 2: HTTP**
- Haz clic en **"Add security group rule"**
- Type: **HTTP**
- Protocol: **TCP**
- Port: **80**
- Source: **Anywhere (0.0.0.0/0)**
- Description: `Vaultwarden web access`

**Regla 3: HTTPS** (para futuro uso)
- Haz clic en **"Add security group rule"**
- Type: **HTTPS**
- Protocol: **TCP**
- Port: **443**
- Source: **Anywhere (0.0.0.0/0)**
- Description: `HTTPS access`

### 1.8 Configurar Almacenamiento

En la sección **"Configure storage"**:

- Tamaño: **8 GB** (suficiente para el workshop)
- Tipo: **gp3** (SSD de propósito general)
- ✅ Free tier: 30 GB disponibles

Deja las demás opciones por defecto.

### 1.9 Revisar y Lanzar

1. En el panel derecho, revisa el **"Summary"**:
   - Número de instancias: **1**
   - Tipo: **t2.micro**
   - AMI: **Amazon Linux 2**
   
2. Haz clic en **"Launch instance"** (botón naranja)

3. Verás un mensaje de éxito: **"Successfully initiated launch of instance"**

4. Haz clic en el **ID de la instancia** (ej: `i-1234567890abcdef0`)

### 1.10 Esperar a que la Instancia Esté Lista

En la página de detalles de la instancia:

1. **Instance state** debe cambiar de `Pending` a `Running` (1-2 minutos)
2. **Status check** debe mostrar `2/2 checks passed` (2-3 minutos)

Mientras esperas, anota:
- **Instance ID**: `i-xxxxxxxxx`
- **Public IPv4 address**: `xx.xx.xx.xx` (la necesitarás para SSH)

---

## 🔌 Paso 2: Conectar por SSH (5 minutos)

### 2.1 Preparar el Archivo de Clave

**En Mac/Linux:**

1. Abre la Terminal
2. Navega a donde descargaste la clave:
   ```bash
   cd ~/Downloads
   ```

3. Cambia los permisos del archivo (requerido):
   ```bash
   chmod 400 vaultwarden-key.pem
   ```

4. (Opcional) Mueve la clave a un lugar seguro:
   ```bash
   mkdir -p ~/.ssh
   mv vaultwarden-key.pem ~/.ssh/
   ```

**En Windows (con OpenSSH):**

1. Abre PowerShell o CMD
2. Navega a donde descargaste la clave:
   ```powershell
   cd Downloads
   ```

3. Los permisos se manejan automáticamente en Windows

### 2.2 Conectarse a la Instancia

**Obtén el comando SSH desde la consola:**

1. En la consola de EC2, selecciona tu instancia
2. Haz clic en **"Connect"** (arriba)
3. Ve a la pestaña **"SSH client"**
4. Copia el comando de ejemplo

**O usa este formato:**

```bash
ssh -i /ruta/a/vaultwarden-key.pem ec2-user@TU_IP_PUBLICA
```

**Ejemplo real:**
```bash
ssh -i ~/.ssh/vaultwarden-key.pem ec2-user@54.123.45.67
```

### 2.3 Aceptar la Huella Digital

La primera vez verás un mensaje como:
```
The authenticity of host '54.123.45.67' can't be established.
ECDSA key fingerprint is SHA256:xxxxx...
Are you sure you want to continue connecting (yes/no)?
```

Escribe **`yes`** y presiona Enter.

### 2.4 ¡Conectado!

Deberías ver algo como:
```
       __|  __|_  )
       _|  (     /   Amazon Linux 2 AMI
      ___|\___|___|

[ec2-user@ip-172-31-xx-xx ~]$
```

¡Felicidades! Estás dentro de tu servidor EC2.

---

## 🐳 Paso 3: Instalar Docker (5 minutos)

Ahora instalaremos Docker para ejecutar Vaultwarden en un contenedor.

### 3.1 Actualizar el Sistema

```bash
sudo yum update -y
```

Esto actualizará todos los paquetes del sistema. Tomará 1-2 minutos.

### 3.2 Instalar Docker

Amazon Linux 2 incluye Docker en sus repositorios extras:

```bash
sudo amazon-linux-extras install docker -y
```

### 3.3 Iniciar el Servicio de Docker

```bash
sudo systemctl start docker
```

### 3.4 Habilitar Docker para Inicio Automático

```bash
sudo systemctl enable docker
```

### 3.5 Agregar Usuario al Grupo Docker (Opcional)

Esto te permite ejecutar comandos Docker sin `sudo`:

```bash
sudo usermod -a -G docker ec2-user
```

**Importante**: Para que este cambio tome efecto, necesitas cerrar sesión y volver a conectarte:

```bash
exit
```

Luego vuelve a conectarte con SSH (usa el mismo comando del Paso 2.2).

### 3.6 Verificar la Instalación

```bash
docker --version
```

Deberías ver algo como:
```
Docker version 20.10.x, build xxxxx
```

Prueba ejecutar un contenedor de prueba:

```bash
docker run hello-world
```

Si ves un mensaje de bienvenida, ¡Docker está funcionando correctamente!

---

## 🔐 Paso 4: Lanzar Vaultwarden (5 minutos)

### 4.1 Descargar y Ejecutar Vaultwarden

Ejecuta este comando para lanzar Vaultwarden:

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

**Explicación del comando:**
- `-d`: Ejecuta en segundo plano (detached)
- `--name vaultwarden`: Nombre del contenedor
- `-e DOMAIN=http://...`: Configura el dominio para permitir HTTP (necesario para el workshop)
- `-e ROCKET_PORT=80`: Puerto interno del contenedor
- `-p 80:80`: Mapea el puerto 80 del contenedor al puerto 80 del host
- `-v /vw-data/:/data/`: Crea un volumen para persistir datos
- `--restart unless-stopped`: Reinicia automáticamente si se detiene
- `vaultwarden/server:latest`: Imagen oficial de Vaultwarden

### 4.2 Verificar que el Contenedor Está Corriendo

```bash
docker ps
```

Deberías ver algo como:
```
CONTAINER ID   IMAGE                       STATUS         PORTS                NAMES
abc123def456   vaultwarden/server:latest   Up 10 seconds  0.0.0.0:80->80/tcp   vaultwarden
```

### 4.3 Ver los Logs (Opcional)

Para ver qué está haciendo Vaultwarden:

```bash
docker logs vaultwarden
```

Deberías ver mensajes indicando que el servidor está corriendo.

---

## ✅ Paso 5: Verificación (3 minutos)

### 5.1 Obtener la IP Pública

Si no la tienes anotada:

1. Ve a la consola de EC2
2. Selecciona tu instancia
3. Copia la **Public IPv4 address**

### 5.2 Acceder a Vaultwarden

1. Abre tu navegador web
2. Ve a: `http://TU_IP_PUBLICA`

**Ejemplo:**
```
http://54.123.45.67
```

⚠️ **Nota**: Usa `http://` (no `https://`). HTTPS requiere configuración adicional.

### 5.3 Crear Tu Primera Cuenta

Deberías ver la página de inicio de Vaultwarden:

1. Haz clic en **"Create account"**
2. Ingresa:
   - Email: tu correo electrónico
   - Nombre: tu nombre
   - Master Password: una contraseña segura
   - Confirma la contraseña
3. Haz clic en **"Submit"**

### 5.4 Iniciar Sesión

1. Usa el email y contraseña que acabas de crear
2. Haz clic en **"Log in"**

¡Felicidades! 🎉 Ahora tienes tu propio gestor de contraseñas auto-hospedado funcionando.

### 5.5 Explorar la Interfaz

Puedes:
- Agregar contraseñas
- Crear carpetas
- Generar contraseñas seguras
- Agregar notas seguras

---

## 🔍 Comandos Útiles de Verificación

### Verificar Estado del Contenedor
```bash
docker ps
```

### Ver Logs en Tiempo Real
```bash
docker logs -f vaultwarden
```

### Verificar que el Puerto 80 Está Escuchando
```bash
sudo netstat -tlnp | grep :80
```

### Reiniciar el Contenedor
```bash
docker restart vaultwarden
```

### Detener el Contenedor
```bash
docker stop vaultwarden
```

### Iniciar el Contenedor
```bash
docker start vaultwarden
```

---

## ❗ Problemas Comunes y Soluciones

### Problema 1: No Puedo Conectarme por SSH

**Error**: `Connection timed out` o `Permission denied`

**Soluciones:**

1. **Verifica el Security Group:**
   - Ve a EC2 → Security Groups
   - Asegúrate de que el puerto 22 esté abierto
   - Verifica que tu IP esté permitida

2. **Verifica los permisos del archivo .pem:**
   ```bash
   chmod 400 vaultwarden-key.pem
   ```

3. **Verifica que estás usando el usuario correcto:**
   - Para Amazon Linux 2: `ec2-user`
   - Para Ubuntu: `ubuntu`

4. **Verifica la IP pública:**
   - Asegúrate de usar la IP pública, no la privada

### Problema 2: No Puedo Acceder a Vaultwarden en el Navegador

**Error**: `This site can't be reached` o `Connection refused`

**Soluciones:**

1. **Verifica el Security Group:**
   - Puerto 80 debe estar abierto a `0.0.0.0/0`

2. **Verifica que el contenedor está corriendo:**
   ```bash
   docker ps
   ```

3. **Verifica los logs del contenedor:**
   ```bash
   docker logs vaultwarden
   ```

4. **Verifica que estás usando HTTP (no HTTPS):**
   - Usa `http://` en la URL

5. **Prueba desde el servidor:**
   ```bash
   curl http://localhost
   ```

### Problema 3: Docker No Se Instala

**Error**: `Package docker not found`

**Solución:**

Asegúrate de estar usando Amazon Linux 2:
```bash
cat /etc/os-release
```

Si no es Amazon Linux 2, usa estos comandos alternativos:
```bash
sudo yum install docker -y
```

### Problema 4: "Permission Denied" al Ejecutar Docker

**Error**: `Got permission denied while trying to connect to the Docker daemon socket`

**Solución:**

1. Agrega tu usuario al grupo docker:
   ```bash
   sudo usermod -a -G docker ec2-user
   ```

2. Cierra sesión y vuelve a conectarte:
   ```bash
   exit
   # Luego vuelve a conectarte por SSH
   ```

3. O usa `sudo` temporalmente:
   ```bash
   sudo docker ps
   ```

### Problema 5: El Contenedor Se Detiene Inmediatamente

**Solución:**

1. Verifica los logs:
   ```bash
   docker logs vaultwarden
   ```

2. Verifica que el puerto 80 no esté en uso:
   ```bash
   sudo netstat -tlnp | grep :80
   ```

3. Intenta con un puerto diferente:
   ```bash
   docker run -d --name vaultwarden -p 8080:80 vaultwarden/server:latest
   ```
   Luego accede a `http://TU_IP:8080`

---

## 📚 Referencia Rápida de Comandos

Para una lista completa de comandos usados en esta fase, consulta:
👉 [comandos.md](comandos.md)

---

## 🎯 ¿Qué Sigue?

¡Felicidades por completar la Fase 1! Ahora entiendes cómo funciona cada componente.

### Opciones:

1. **Practica más:**
   - Agrega contraseñas a Vaultwarden
   - Explora las funcionalidades
   - Prueba la extensión del navegador

2. **Continúa con Fase 2:**
   - Aprende a automatizar todo esto con un script
   - 👉 [Fase 2: Automatización con Script](../fase-2-script/README.md)

3. **Limpia los recursos:**
   - Si terminaste, elimina los recursos para evitar costos
   - 👉 [Guía de limpieza](../limpieza.md)

---

## 🔒 Nota de Seguridad

⚠️ **Este despliegue es para fines educativos**

Para producción, deberías:
- Configurar HTTPS con certificados SSL/TLS
- Usar un dominio personalizado
- Restringir el acceso SSH a IPs específicas
- Configurar backups automáticos
- Usar contraseñas fuertes y 2FA
- Mantener el sistema actualizado

---

## 💡 Consejos Adicionales

1. **Guarda tu IP pública**: La necesitarás cada vez que quieras acceder
2. **Anota tu Instance ID**: Para identificar tu instancia fácilmente
3. **Guarda tu archivo .pem**: Sin él, no podrás conectarte por SSH
4. **Revisa los costos**: Consulta [costos.md](../costos.md) regularmente

---

**¿Preguntas o problemas?** Abre un Issue en el repositorio.

**¿Todo funcionó?** ¡Genial! Continúa con la [Fase 2](../fase-2-script/README.md) para aprender a automatizar este proceso.
