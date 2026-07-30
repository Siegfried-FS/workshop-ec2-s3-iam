# 🔒 Configuración de HTTPS para Vaultwarden

Esta guía te ayudará a configurar Vaultwarden con HTTPS usando Caddy como reverse proxy.

## 📋 Prerequisitos

Antes de comenzar, asegúrate de tener:

- ✅ Un dominio registrado (ej: `tudominio.com`)
- ✅ Acceso a Route 53 o cualquier proveedor DNS
- ✅ Una instancia EC2 corriendo Amazon Linux 2 o 2023
- ✅ Security Group con puertos 22, 80 y 443 abiertos

## 🚀 Pasos de Configuración

### 1. Configurar DNS en Route 53

#### Si NO tienes un dominio en Route 53

1. **Registrar un dominio** (si no tienes uno):
   - Ve a [Route 53 Console](https://console.aws.amazon.com/route53/)
   - Click en **"Registered domains"** → **"Register domain"**
   - Busca y compra un dominio (ej: `tudominio.com`)
   - Costo: ~$12/año dependiendo del TLD (.com, .net, etc.)
   - Espera 10-15 minutos para que se complete el registro

2. **Crear una Hosted Zone** (si registraste el dominio fuera de AWS):
   - Ve a [Route 53 Console](https://console.aws.amazon.com/route53/)
   - Click en **"Hosted zones"** → **"Create hosted zone"**
   - Domain name: `tudominio.com`
   - Type: **Public hosted zone**
   - Click **"Create hosted zone"**
   - Costo: $0.50/mes por zona hospedada
   - **IMPORTANTE**: Copia los 4 servidores NS (nameservers) que aparecen
   - Ve a tu registrador de dominios (GoDaddy, Namecheap, etc.)
   - Actualiza los nameservers con los 4 de Route 53
   - Espera 24-48 horas para propagación completa

#### Crear el registro A para tu subdominio

1. Ve a [Route 53 Console](https://console.aws.amazon.com/route53/)
2. Click en **"Hosted zones"**
3. Selecciona tu dominio (ej: `tudominio.com`)
4. Click en **"Create record"**
5. Configura:
   - **Record name**: `vault` (o el subdominio que prefieras)
     - Esto creará: `vault.tudominio.com`
   - **Record type**: **A - Routes traffic to an IPv4 address**
   - **Value**: La IP pública de tu instancia EC2
     - Para obtenerla: Ve a EC2 Console → Selecciona tu instancia → Copia "Public IPv4 address"
   - **TTL**: `300` (5 minutos)
   - **Routing policy**: Simple routing
6. Click en **"Create records"**

**Ejemplo de configuración:**
```
Nombre del registro: vault.tudominio.com
Tipo: A
Valor: 54.123.45.67
TTL: 300
```

#### Verificar la configuración DNS

Espera 5-10 minutos y verifica que el DNS funciona:

```bash
# Desde tu computadora o EC2
nslookup vault.tudominio.com

# O con dig
dig vault.tudominio.com

# Debe mostrar la IP de tu EC2
```

**Ejemplo de salida correcta:**
```
Server:		8.8.8.8
Address:	8.8.8.8#53

Non-authoritative answer:
Name:	vault.tudominio.com
Address: 54.123.45.67
```

#### Alternativas a Route 53

Si no quieres usar Route 53, puedes usar cualquier proveedor DNS:

**Cloudflare (Gratis)**:
1. Registra tu dominio en Cloudflare o transfiere uno existente
2. Agrega un registro A: `vault` → IP de tu EC2
3. **IMPORTANTE**: Desactiva el proxy de Cloudflare (nube gris, no naranja)
4. Espera 5-10 minutos

**Namecheap, GoDaddy, Google Domains, etc.**:
1. Ve al panel de DNS de tu proveedor
2. Agrega un registro A:
   - Host: `vault`
   - Type: `A`
   - Value: IP de tu EC2
   - TTL: `300` o `Automatic`
3. Guarda los cambios
4. Espera 5-10 minutos

**DuckDNS (Gratis - para pruebas)**:
1. Ve a https://www.duckdns.org/
2. Crea una cuenta con GitHub/Google
3. Crea un subdominio: `tuvault.duckdns.org`
4. Actualiza la IP con tu EC2
5. Usa `tuvault.duckdns.org` como tu DOMAIN en el script

### 2. Configurar Security Group

Asegúrate de que tu Security Group tenga estas reglas:

| Tipo | Puerto | Protocolo | Origen | Descripción |
|------|--------|-----------|--------|-------------|
| SSH | 22 | TCP | Tu IP o 0.0.0.0/0 | SSH access |
| HTTP | 80 | TCP | 0.0.0.0/0 | HTTP (redirige a HTTPS) |
| HTTPS | 443 | TCP | 0.0.0.0/0 | HTTPS access |

### 3. Configurar SMTP (Opcional pero Recomendado)

Vaultwarden necesita SMTP para enviar correos de verificación y notificaciones.

**IMPORTANTE: Zoho Free NO soporta SMTP externo**

Si usas Zoho Free, debes:
- Usar Gmail (recomendado y gratis)
- Pagar Zoho Mail Professional (~$1/mes)
- O deshabilitar verificación de correo (no recomendado)

#### Opción A: Configurar Gmail SMTP (Recomendado)

1. Ve a tu cuenta Google: https://myaccount.google.com/security
2. Habilita **"Verificación en 2 pasos"**
3. Ve a **"Contraseñas de aplicaciones"**: https://myaccount.google.com/apppasswords
4. Genera una contraseña:
   - Selecciona app: **Correo**
   - Selecciona dispositivo: **Otro (nombre personalizado)**
   - Nombre: **Vaultwarden**
   - Copia la contraseña generada (16 caracteres sin espacios)

5. Usa estos datos en el script:
```bash
SMTP_HOST="smtp.gmail.com"
SMTP_PORT="587"
SMTP_SECURITY="starttls"
SMTP_USERNAME="tu-correo@gmail.com"
SMTP_PASSWORD="abcd efgh ijkl mnop"  # Quita los espacios: abcdefghijklmnop
SMTP_FROM="tu-correo@gmail.com"
SMTP_FROM_NAME="Vaultwarden"
```

#### Opción B: Deshabilitar Verificación de Correo

Si no quieres configurar SMTP, puedes deshabilitar la verificación:

En el script, deja las variables SMTP vacías y Vaultwarden funcionará sin correos.

**Nota**: Sin SMTP no recibirás correos de verificación ni notificaciones, pero Vaultwarden funcionará normalmente para guardar contraseñas.

### 4. Modificar el Script

1. Descarga o copia el script `install-vaultwarden-https.sh`

2. Edita las variables al inicio del script:

```bash
# Tu dominio completo
DOMAIN="vault.tudominio.com"

# Tu email para notificaciones de Let's Encrypt
EMAIL="tu@email.com"

# Configuración SMTP con Gmail (opcional)
SMTP_HOST="smtp.gmail.com"
SMTP_PORT="587"
SMTP_SECURITY="starttls"
SMTP_USERNAME="tu-correo@gmail.com"
SMTP_PASSWORD="abcdefghijklmnop"  # Contraseña de aplicación SIN espacios
SMTP_FROM="tu-correo@gmail.com"
SMTP_FROM_NAME="Vaultwarden"

# Panel de Administración (opcional)
# Genera un token con: openssl rand -base64 48
# Deja vacío para deshabilitar el panel
ADMIN_TOKEN=""
```

**Nota sobre el Panel de Administración**:
- El panel admin NO es necesario para uso normal de Vaultwarden
- Solo lo necesitas si quieres administrar usuarios, ver estadísticas, etc.
- Para habilitarlo: genera un token con `openssl rand -base64 48` y pégalo en ADMIN_TOKEN
- Accederás al panel en: `https://tu-dominio.com/admin`

3. Guarda el archivo

### 5. Ejecutar el Script

```bash
# Dar permisos de ejecución
chmod +x install-vaultwarden-https.sh

# Ejecutar como root
sudo ./install-vaultwarden-https.sh
```

### 6. Esperar a que Caddy Obtenga el Certificado

El script tardará aproximadamente 2-3 minutos. Caddy obtendrá automáticamente el certificado SSL de Let's Encrypt.

Puedes ver el progreso con:

```bash
sudo journalctl -u caddy -f
```

### 7. Acceder a Vaultwarden

Una vez completado, accede a:

```
https://vault.tudominio.com
```

¡Deberías ver Vaultwarden con HTTPS funcionando! 🎉

## 🔍 Verificación

### Verificar que Todo Está Corriendo

```bash
# Verificar Docker
sudo docker ps

# Verificar Caddy
sudo systemctl status caddy

# Ver logs de Caddy
sudo journalctl -u caddy -n 50

# Ver logs de Vaultwarden
sudo docker logs vaultwarden
```

### Verificar el Certificado SSL

```bash
# Verificar certificado
curl -I https://vault.tudominio.com

# Ver detalles del certificado
openssl s_client -connect vault.tudominio.com:443 -servername vault.tudominio.com
```

## 🔧 Solución de Problemas

### Error: "certificate not found"

**Causa**: DNS no está propagado o no apunta a la IP correcta

**Solución**:
```bash
# Verificar DNS
nslookup vault.tudominio.com

# Debe mostrar la IP de tu EC2
# Si no, espera más tiempo o verifica Route 53
```

### Error: "connection refused" en puerto 443

**Causa**: Security Group no tiene puerto 443 abierto

**Solución**:
1. Ve a EC2 → Security Groups
2. Selecciona tu Security Group
3. Edit inbound rules
4. Agrega regla: HTTPS (443), TCP, 0.0.0.0/0

### Error: "too many certificates already issued"

**Causa**: Let's Encrypt tiene límite de 5 certificados por semana por dominio

**Solución**:
- Espera una semana
- O usa un subdominio diferente
- O usa el ambiente de staging de Let's Encrypt (para pruebas)

### Caddy no inicia

**Ver logs detallados**:
```bash
sudo journalctl -u caddy -xe
```

**Verificar configuración**:
```bash
sudo caddy validate --config /etc/caddy/Caddyfile
```

**Reiniciar Caddy**:
```bash
sudo systemctl restart caddy
```

### Vaultwarden no responde

**Verificar que el contenedor está corriendo**:
```bash
sudo docker ps
```

**Ver logs**:
```bash
sudo docker logs vaultwarden
```

**Reiniciar contenedor**:
```bash
sudo docker restart vaultwarden
```

### Error SMTP: "5.7.8 Access Restricted" (Zoho)

**Causa**: Zoho Free no permite SMTP externo

**Solución**:
1. Usa Gmail en lugar de Zoho (ver sección "Configurar SMTP")
2. O paga Zoho Mail Professional
3. O deshabilita verificación de correo

### Error SMTP con Gmail

**Verificar**:
1. Que habilitaste verificación en 2 pasos
2. Que generaste una contraseña de aplicación (no uses tu contraseña normal)
3. Que quitaste los espacios de la contraseña de aplicación
4. Que el correo y usuario son correctos

**Ver logs SMTP**:
```bash
sudo docker logs vaultwarden | grep -i smtp
```

## 🔄 Renovación de Certificados

Caddy renueva los certificados automáticamente. No necesitas hacer nada.

Para verificar cuándo expira tu certificado:

```bash
echo | openssl s_client -servername vault.tudominio.com -connect vault.tudominio.com:443 2>/dev/null | openssl x509 -noout -dates
```

## 🛠️ Comandos Útiles

### Gestión de Caddy

```bash
# Ver estado
sudo systemctl status caddy

# Reiniciar
sudo systemctl restart caddy

# Detener
sudo systemctl stop caddy

# Ver logs en tiempo real
sudo journalctl -u caddy -f

# Ver configuración
sudo cat /etc/caddy/Caddyfile

# Validar configuración
sudo caddy validate --config /etc/caddy/Caddyfile
```

### Gestión de Vaultwarden

```bash
# Ver logs
sudo docker logs vaultwarden

# Logs en tiempo real
sudo docker logs -f vaultwarden

# Reiniciar
sudo docker restart vaultwarden

# Detener
sudo docker stop vaultwarden

# Iniciar
sudo docker start vaultwarden

# Ver estadísticas
sudo docker stats vaultwarden
```

### Backups

```bash
# Crear backup de datos
sudo tar -czf vaultwarden-backup-$(date +%Y%m%d).tar.gz /vw-data/

# Copiar backup a tu máquina local (desde tu computadora)
scp -i ~/.ssh/tu-clave.pem ec2-user@vault.tudominio.com:~/vaultwarden-backup-*.tar.gz ~/Downloads/
```

## 📊 Monitoreo

### Ver Uso de Recursos

```bash
# CPU y memoria
htop

# Uso de disco
df -h

# Uso de Docker
sudo docker system df
```

### Logs de Acceso

Caddy guarda logs de acceso en:

```bash
sudo tail -f /var/log/caddy/access.log
```

## 🔐 Seguridad Adicional

### Restringir SSH

Edita el Security Group para permitir SSH solo desde tu IP:

```
SSH (22), TCP, TU_IP/32
```

### Habilitar 2FA en Vaultwarden

1. Accede a Vaultwarden
2. Ve a Settings → Two-step Login
3. Configura tu método preferido (Authenticator, Email, etc.)

### Backups Automáticos

Crea un cron job para backups diarios:

```bash
sudo crontab -e
```

Agrega:
```
0 2 * * * tar -czf /root/vaultwarden-backup-$(date +\%Y\%m\%d).tar.gz /vw-data/
```

## 📚 Recursos Adicionales

- [Documentación de Caddy](https://caddyserver.com/docs/)
- [Vaultwarden Wiki](https://github.com/dani-garcia/vaultwarden/wiki)
- [Let's Encrypt](https://letsencrypt.org/)
- [Route 53 Documentation](https://docs.aws.amazon.com/route53/)

## ❓ Preguntas Frecuentes

### ¿Cuánto cuesta?

- **Dominio**: ~$12/año (varía según TLD)
- **EC2 t2.micro**: Gratis en Free Tier (12 meses), luego ~$8-10/mes
- **Route 53**: $0.50/mes por zona hospedada + $0.40 por millón de consultas
- **Certificado SSL**: Gratis con Let's Encrypt

### ¿Puedo usar otro proveedor DNS?

Sí, puedes usar cualquier proveedor DNS (Cloudflare, Namecheap, GoDaddy, etc.). Solo necesitas crear un registro A apuntando a tu IP de EC2.

### ¿Puedo usar nginx en lugar de Caddy?

Sí, pero Caddy es más simple porque obtiene certificados SSL automáticamente. Con nginx necesitas configurar Certbot manualmente.

### ¿Los datos están seguros?

Sí, Vaultwarden encripta todos los datos. Además, con HTTPS, la comunicación entre tu navegador y el servidor está encriptada.

### ¿Qué pasa si cambio la IP de mi EC2?

Necesitas actualizar el registro A en Route 53 con la nueva IP. Caddy obtendrá un nuevo certificado automáticamente.

---

**¿Configuraste HTTPS exitosamente?** ¡Felicidades! Ahora tienes un gestor de contraseñas seguro y profesional. 🎉

**¿Problemas?** 
- 🐛 Abre un Issue en GitHub
- 💬 Contacta al autor: https://linktr.ee/siegfried.fs
- 🤝 Únete a AWS User Group Playa Vicente

---

**Creado por Roberto Flores para AWS User Group Playa Vicente**
