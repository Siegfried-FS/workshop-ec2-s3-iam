# 📜 Fase 2: Automatización con Script

⏱️ **Tiempo estimado**: 20 minutos  
🎯 **Nivel**: Intermedio  
📋 **Prerequisitos**: [Completar Fase 1](../fase-1-manual/README.md) o conocimientos básicos de AWS EC2

## 📖 Introducción

En la Fase 1 aprendiste a desplegar Vaultwarden manualmente. Ahora automatizaremos todo ese proceso usando un script de shell y la funcionalidad **User Data** de EC2.

### ⚠️ Nota Importante sobre HTTPS

Este script configura Vaultwarden con **HTTP** (sin SSL/TLS) para fines educativos y demostración. 

**Limitaciones sin HTTPS:**
- ⚠️ Vaultwarden mostrará una advertencia sobre contexto no seguro
- ⚠️ Algunas funcionalidades pueden estar limitadas
- ⚠️ **NO usar en producción sin HTTPS**

**Para uso en producción:**
- Necesitas configurar HTTPS con un dominio y certificado SSL
- Ver la sección "Configurar HTTPS para Producción" al final de este documento
- O usar la Fase 4 (opcional) que incluye configuración completa de HTTPS

Este workshop se enfoca en los conceptos básicos de despliegue y automatización. HTTPS es un tema avanzado que requiere dominio, DNS y certificados.

### ¿Qué es User Data?

User Data es una característica de AWS EC2 que te permite ejecutar scripts automáticamente cuando una instancia se inicia por primera vez. Es perfecto para:
- Instalar software
- Configurar servicios
- Automatizar tareas repetitivas

### ¿Qué aprenderás?

- ✅ Cómo usar scripts de shell para automatización
- ✅ Cómo funciona User Data en EC2
- ✅ Cómo verificar que un script se ejecutó correctamente
- ✅ Cómo depurar problemas en scripts de automatización

### Ventajas de la Automatización

| Manual (Fase 1) | Automatizado (Fase 2) |
|-----------------|----------------------|
| 30 minutos de trabajo | 5 minutos de configuración |
| Propenso a errores humanos | Consistente y repetible |
| Requiere conocimiento técnico | Ejecuta automáticamente |
| Difícil de documentar | El script es la documentación |

---

## 📋 Paso 1: Revisar el Script (2 minutos)

Antes de usar el script, es importante entender qué hace.

### 1.1 Abrir el Script

El script está en este repositorio: [`install-vaultwarden.sh`](install-vaultwarden.sh)

### 1.2 ¿Qué Hace el Script?

El script automatiza todos los pasos de la Fase 1:

1. **Actualiza el sistema**: `yum update -y`
2. **Instala Docker**: `amazon-linux-extras install docker -y`
3. **Inicia Docker**: `systemctl start docker`
4. **Habilita Docker**: Para que inicie automáticamente
5. **Configura permisos**: Agrega ec2-user al grupo docker
6. **Crea directorio de datos**: `/vw-data/`
7. **Descarga Vaultwarden**: `docker pull vaultwarden/server:latest`
8. **Lanza el contenedor**: Con todas las configuraciones necesarias
9. **Verifica la instalación**: Comprueba que todo funciona
10. **Registra logs**: Guarda todo en `/var/log/vaultwarden-install.log`

### 1.3 Características del Script

- ✅ **Logging completo**: Cada paso se registra con timestamp
- ✅ **Manejo de errores**: Se detiene si algo falla
- ✅ **Idempotente**: Puede ejecutarse múltiples veces sin problemas
- ✅ **Comentarios en español**: Fácil de entender y modificar
- ✅ **Verificación automática**: Comprueba que Vaultwarden está corriendo

---

## 📝 Paso 2: Copiar el Script (2 minutos)

### 2.1 Abrir el Archivo del Script

1. Ve a [`install-vaultwarden.sh`](install-vaultwarden.sh)
2. Haz clic en el botón **"Raw"** (arriba a la derecha)
3. Selecciona todo el contenido (`Ctrl+A` o `Cmd+A`)
4. Copia el contenido (`Ctrl+C` o `Cmd+C`)

### 2.2 Mantener el Script a Mano

Pega el script en un editor de texto temporal. Lo necesitarás en el siguiente paso.

**Tip**: También puedes descargarlo directamente:
```bash
curl -O https://raw.githubusercontent.com/TU_USUARIO/TU_REPO/main/fase-2-script/install-vaultwarden.sh
```

---

## 🚀 Paso 3: Lanzar EC2 con User Data (10 minutos)

Ahora lanzaremos una nueva instancia EC2 y pegaremos el script en el campo User Data.

### 3.1 Acceder a la Consola de EC2

1. Inicia sesión en [AWS Console](https://console.aws.amazon.com/)
2. Busca **"EC2"** en la barra de búsqueda
3. Haz clic en **"EC2"**

### 3.2 Iniciar el Asistente

1. Haz clic en **"Launch instance"**

### 3.3 Configuración Básica

**Nombre:**
```
Vaultwarden-Automated
```

**AMI:**
- Selecciona **"Amazon Linux 2 AMI (HVM)"**
- Arquitectura: **64-bit (x86)**

**Tipo de instancia:**
- **t2.micro** (Free tier eligible)

**Par de claves:**
- Usa el mismo par de claves de la Fase 1
- O crea uno nuevo si lo prefieres

### 3.4 Configurar Security Group

**Importante**: Usa el mismo Security Group de la Fase 1 o crea uno nuevo con estas reglas:

| Tipo | Puerto | Origen | Descripción |
|------|--------|--------|-------------|
| SSH | 22 | My IP o 0.0.0.0/0 | SSH access |
| HTTP | 80 | 0.0.0.0/0 | Vaultwarden web |
| HTTPS | 443 | 0.0.0.0/0 | HTTPS (futuro) |

### 3.5 Configurar User Data (¡Paso Clave!)

1. Desplázate hacia abajo hasta **"Advanced details"**
2. Haz clic para expandir la sección
3. Busca el campo **"User data"** (al final)
4. **Pega el script completo** que copiaste en el Paso 2

**Importante**:
- ✅ Pega el script completo, incluyendo `#!/bin/bash`
- ✅ No agregues comillas ni modifiques el formato
- ✅ El script debe empezar con `#!/bin/bash` en la primera línea

### 3.6 Revisar y Lanzar

1. Revisa el resumen en el panel derecho
2. Haz clic en **"Launch instance"**
3. Anota el **Instance ID** y la **IP pública**

---

## ⏳ Paso 4: Esperar y Verificar (5 minutos)

### 4.1 Esperar a que la Instancia Inicie

1. Ve a la lista de instancias en EC2
2. Espera a que el **Instance state** sea `Running`
3. Espera a que **Status check** muestre `2/2 checks passed`

⏱️ **Tiempo estimado**: 2-3 minutos

### 4.2 Esperar a que el Script Termine

El script tarda aproximadamente **3-5 minutos** en completarse después de que la instancia esté corriendo.

**¿Cómo saber si terminó?**

Opción 1: Espera 5 minutos y prueba acceder a Vaultwarden

Opción 2: Conéctate por SSH y revisa los logs (ver siguiente sección)

### 4.3 Verificar los Logs (Opcional pero Recomendado)

Conéctate por SSH a tu instancia:

```bash
ssh -i ~/.ssh/vaultwarden-key.pem ec2-user@TU_IP_PUBLICA
```

Ver el log de instalación:

```bash
cat /var/log/vaultwarden-install.log
```

O ver los logs en tiempo real mientras se ejecuta:

```bash
tail -f /var/log/vaultwarden-install.log
```

**Busca estas líneas al final:**
```
========================================
Instalación completada exitosamente
========================================
```

### 4.4 Verificar que el Contenedor Está Corriendo

```bash
docker ps
```

Deberías ver:
```
CONTAINER ID   IMAGE                       STATUS         PORTS
abc123def456   vaultwarden/server:latest   Up 2 minutes   0.0.0.0:80->80/tcp
```

---

## ✅ Paso 5: Acceder a Vaultwarden (1 minuto)

### 5.1 Obtener la IP Pública

Si no la tienes anotada:
1. Ve a la consola de EC2
2. Selecciona tu instancia
3. Copia la **Public IPv4 address**

### 5.2 Abrir en el Navegador

Abre tu navegador y ve a:
```
http://TU_IP_PUBLICA
```

**Ejemplo:**
```
http://54.123.45.67
```

### 5.3 Crear Tu Cuenta

Si ves la página de Vaultwarden, ¡el script funcionó perfectamente! 🎉

1. Haz clic en **"Create account"**
2. Ingresa tu información
3. Crea tu contraseña maestra
4. Inicia sesión

---

## 🔍 Verificación Avanzada

### Verificar el Estado del Sistema

```bash
# Ver estado de Docker
sudo systemctl status docker

# Ver contenedores corriendo
docker ps

# Ver logs del contenedor
docker logs vaultwarden

# Ver uso de recursos
docker stats vaultwarden

# Verificar puerto 80
sudo netstat -tlnp | grep :80
```

### Verificar el Archivo de Estado

El script crea un archivo indicando que la instalación se completó:

```bash
cat /var/lib/cloud/instance/vaultwarden-installed
```

### Ver Logs de User Data

AWS guarda los logs de User Data en:

```bash
# Ver logs de cloud-init
sudo cat /var/log/cloud-init-output.log

# Ver logs específicos de nuestro script
sudo cat /var/log/vaultwarden-install.log
```

---

## 🔧 Solución de Problemas

Si algo no funciona, consulta: [troubleshooting.md](troubleshooting.md)

### Problemas Comunes

#### 1. La Página No Carga

**Síntomas**: `This site can't be reached` en el navegador

**Soluciones**:
1. Verifica el Security Group (puerto 80 abierto)
2. Espera 5 minutos más (el script puede estar ejecutándose)
3. Revisa los logs: `cat /var/log/vaultwarden-install.log`

#### 2. El Script No Se Ejecutó

**Síntomas**: No existe `/var/log/vaultwarden-install.log`

**Soluciones**:
1. Verifica que pegaste el script en User Data correctamente
2. Revisa los logs de cloud-init:
   ```bash
   sudo cat /var/log/cloud-init-output.log
   ```
3. Busca errores de sintaxis en el script

#### 3. Docker No Está Instalado

**Síntomas**: `docker: command not found`

**Soluciones**:
1. Verifica que usaste Amazon Linux 2 (no Amazon Linux 2023)
2. Revisa los logs para ver dónde falló:
   ```bash
   sudo cat /var/log/vaultwarden-install.log
   ```
3. Ejecuta el script manualmente:
   ```bash
   sudo bash /var/lib/cloud/instance/user-data.txt
   ```

#### 4. El Contenedor No Inicia

**Síntomas**: `docker ps` no muestra el contenedor

**Soluciones**:
1. Ver todos los contenedores (incluyendo detenidos):
   ```bash
   docker ps -a
   ```
2. Ver logs del contenedor:
   ```bash
   docker logs vaultwarden
   ```
3. Verificar que el puerto 80 no esté en uso:
   ```bash
   sudo netstat -tlnp | grep :80
   ```

---

## 🎓 Comparación: Manual vs Automatizado

### Tiempo Invertido

| Tarea | Manual | Automatizado |
|-------|--------|--------------|
| Configuración inicial | 10 min | 5 min |
| Instalación de software | 10 min | Automático |
| Configuración de servicios | 5 min | Automático |
| Lanzamiento de Vaultwarden | 5 min | Automático |
| **Total** | **30 min** | **5 min + espera** |

### Ventajas de la Automatización

✅ **Consistencia**: El script siempre hace lo mismo  
✅ **Repetibilidad**: Puedes crear múltiples instancias idénticas  
✅ **Documentación**: El script documenta el proceso  
✅ **Menos errores**: No hay errores de tipeo  
✅ **Escalabilidad**: Fácil de replicar en múltiples instancias  

### Cuándo Usar Cada Método

**Manual (Fase 1)**:
- Aprendiendo AWS por primera vez
- Necesitas entender cada paso
- Configuración única o experimental

**Automatizado (Fase 2)**:
- Despliegues repetidos
- Entornos de desarrollo/pruebas
- Necesitas consistencia
- Quieres ahorrar tiempo

---

## 🔄 Modificar el Script

### Personalizar el Script

Puedes modificar el script para:

1. **Cambiar el puerto**:
   ```bash
   docker run -d --name vaultwarden -p 8080:80 ...
   ```

2. **Agregar variables de entorno**:
   ```bash
   docker run -d --name vaultwarden \
     -e SIGNUPS_ALLOWED=false \
     -p 80:80 ...
   ```

3. **Usar una versión específica**:
   ```bash
   docker pull vaultwarden/server:1.30.0
   ```

4. **Agregar más logging**:
   ```bash
   log "Mi mensaje personalizado"
   ```

### Probar Cambios

1. Modifica el script localmente
2. Lanza una nueva instancia con el script modificado
3. Verifica que funciona
4. Termina la instancia de prueba

---

## 📚 Recursos Adicionales

### Documentación de User Data

- [User Data y Scripts de Shell](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html)
- [Ejemplos de User Data](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html#user-data-shell-scripts)

### Documentación de Docker

- [Docker Run Reference](https://docs.docker.com/engine/reference/run/)
- [Vaultwarden Wiki](https://github.com/dani-garcia/vaultwarden/wiki)

---

## 🎯 ¿Qué Sigue?

¡Felicidades por completar la Fase 2! Ahora sabes cómo automatizar despliegues con scripts.

### Opciones:

1. **Experimenta más:**
   - Modifica el script para agregar funcionalidades
   - Prueba diferentes configuraciones de Vaultwarden
   - Crea scripts para otras aplicaciones

2. **Continúa con Fase 3:**
   - Aprende Infrastructure as Code con AWS CDK
   - Automatización completa con código TypeScript
   - 👉 [Fase 3: Infrastructure as Code](../fase-3-cdk/README.md)

3. **Limpia los recursos:**
   - No olvides eliminar las instancias de prueba
   - 👉 [Guía de limpieza](../limpieza.md)

---

## 💡 Mejores Prácticas

### Para Scripts de User Data

1. **Siempre incluye logging**: Facilita la depuración
2. **Maneja errores**: Usa `|| error_exit` después de comandos críticos
3. **Verifica prerequisitos**: Comprueba que el sistema es el correcto
4. **Documenta bien**: Comenta cada sección del script
5. **Prueba en instancias de prueba**: Antes de usar en producción

### Para Producción

Si vas a usar esto en producción, considera:

- ✅ Usar HTTPS con certificados SSL/TLS
- ✅ Configurar backups automáticos
- ✅ Usar AWS Secrets Manager para credenciales
- ✅ Implementar monitoreo con CloudWatch
- ✅ Configurar alertas de seguridad
- ✅ Usar un dominio personalizado

---

**¿Problemas?** Consulta [troubleshooting.md](troubleshooting.md)

**¿Todo funcionó?** ¡Excelente! Continúa con la [Fase 3](../fase-3-cdk/README.md)

**¿Preguntas?**
- 💬 Contacto: https://linktr.ee/siegfried.fs
- 🤝 AWS User Group Playa Vicente
- 🐛 GitHub Issues

---

**Creado con ❤️ por Roberto Flores para AWS User Group Playa Vicente**


---

## 🔒 Configurar HTTPS para Producción

Si quieres usar Vaultwarden en producción con HTTPS, necesitarás:

### Requisitos

1. **Un dominio** (ej: `tudominio.com`)
   - Puedes registrarlo en Route 53 (~$12/año)
   - O usar un dominio existente de cualquier registrador
2. **DNS configurado** (Route 53, Cloudflare, Namecheap, etc.)
3. **Certificado SSL** (Let's Encrypt es gratis y automático con Caddy)
4. **Reverse proxy** (Caddy - recomendado por su simplicidad)

### Guía Completa de HTTPS

Para una guía detallada paso a paso sobre cómo configurar HTTPS, consulta:

👉 **[HTTPS-SETUP.md](HTTPS-SETUP.md)** - Guía completa con:
- Cómo registrar un dominio en Route 53 (o usar otro proveedor)
- Configuración de DNS paso a paso
- Configuración de SMTP con Gmail (Zoho Free no funciona)
- Script automático con Caddy
- Solución de problemas
- Comandos útiles

### Resumen Rápido

Si ya tienes un dominio y sabes configurar DNS:

1. **Configurar DNS:**
   - Crear registro A: `vault.tudominio.com` → IP de tu EC2
   - Esperar 5-10 minutos para propagación

2. **Abrir puerto 443 en Security Group:**
   - Agregar regla: HTTPS (443), TCP, 0.0.0.0/0

3. **Usar el script con HTTPS:**
   ```bash
   # Descargar el script
   curl -O https://raw.githubusercontent.com/TU_USUARIO/TU_REPO/main/fase-2-script/install-vaultwarden-https.sh
   
   # Editar las variables DOMAIN y EMAIL
   nano install-vaultwarden-https.sh
   
   # Ejecutar
   chmod +x install-vaultwarden-https.sh
   sudo ./install-vaultwarden-https.sh
   ```

4. **Esperar 1-2 minutos** para que Caddy obtenga el certificado SSL

5. **Acceder a:** `https://vault.tudominio.com`

### ¿No tienes dominio?

**Opciones gratuitas para pruebas:**
- **DuckDNS**: Subdominio gratis (ej: `tuvault.duckdns.org`)
- **FreeDNS**: Varios dominios gratuitos disponibles
- **No-IP**: Dominio dinámico gratis

**Para producción:**
- Registra un dominio en Route 53, Namecheap, GoDaddy, etc.
- Costo típico: $10-15/año

### Alternativa: AWS Certificate Manager + ALB

Para entornos de producción empresariales:

1. Crear certificado en ACM para tu dominio
2. Crear Application Load Balancer
3. Configurar listener HTTPS (443) con el certificado
4. Target group apuntando a tu EC2 en puerto 80
5. Configurar Route 53 para apuntar al ALB

**Ventajas:**
- ✅ Certificado gestionado por AWS
- ✅ Renovación automática
- ✅ Mejor para alta disponibilidad
- ✅ Puede agregar WAF para seguridad

**Desventajas:**
- 💰 Costo adicional (~$16/mes por el ALB)
- 🔧 Más complejo de configurar

---

## 📚 Recursos Adicionales para HTTPS

- 📖 **[HTTPS-SETUP.md](HTTPS-SETUP.md)** - Guía completa paso a paso
- [Documentación de Caddy](https://caddyserver.com/docs/)
- [Let's Encrypt](https://letsencrypt.org/)
- [Vaultwarden con HTTPS](https://github.com/dani-garcia/vaultwarden/wiki/Enabling-HTTPS)
- [AWS Certificate Manager](https://aws.amazon.com/certificate-manager/)
- [Route 53 Documentation](https://docs.aws.amazon.com/route53/)

---

**¿Configuraste HTTPS exitosamente?** ¡Excelente! Ahora tienes un gestor de contraseñas seguro y auto-hospedado.

**¿Prefieres seguir con el workshop?** Continúa con la [Fase 3: CDK](../fase-3-cdk/README.md)
