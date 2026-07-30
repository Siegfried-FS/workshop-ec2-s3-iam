# 🔒 Seguridad y Protección de Credenciales

## ✅ Archivos Protegidos (NO se suben a GitHub)

El archivo `.gitignore` está configurado para **NO subir** los siguientes archivos:

### 1. Archivos Personales
```
*-personal.sh          # Cualquier script con sufijo -personal
*-personal.md          # Cualquier documento personal
datos-personales.txt   # Archivo de datos personales
```

**Ejemplo protegido:**
- ✅ `install-vaultwarden-https-personal.sh` - **NO SE SUBE**

### 2. Claves SSH
```
*.pem                  # Claves privadas SSH
*.ppk                  # Claves PuTTY
```

### 3. Variables de Entorno
```
.env                   # Archivos de entorno
.env.local
.env.*.local
```

### 4. Configuración de AWS
```
.aws/                  # Credenciales de AWS CLI
```

### 5. Logs
```
*.log                  # Archivos de log
logs/                  # Directorio de logs
```

## 📝 Archivos Públicos (SÍ se suben a GitHub)

Estos archivos están **limpios** y **sin credenciales**:

### Scripts Genéricos
- ✅ `install-vaultwarden.sh` - Variables con placeholders
- ✅ `install-vaultwarden-https.sh` - Variables con placeholders
- ✅ `launch-ec2-cli.sh` - Variables con placeholders

**Ejemplo de placeholders seguros:**
```bash
DOMAIN="tu-dominio.com"
EMAIL="tu@email.com"
SMTP_USERNAME="tu@gmail.com"
SMTP_PASSWORD="tu-contraseña-de-app"
```

## 🔍 Verificación Antes de Subir

Antes de hacer `git push`, ejecuta el script de verificación:

```bash
# Dar permisos
chmod +x check-credentials.sh

# Ejecutar verificación
./check-credentials.sh
```

Este script verifica:
- ✅ Que no haya dominios personales
- ✅ Que no haya emails personales
- ✅ Que no haya contraseñas
- ✅ Que archivos personales estén en .gitignore

## ⚠️ Qué Hacer Si Subiste Credenciales Por Error

Si accidentalmente subiste credenciales a GitHub:

### 1. Revocar Credenciales Inmediatamente

**Gmail:**
1. Ve a https://myaccount.google.com/apppasswords
2. Revoca la contraseña de aplicación comprometida
3. Genera una nueva

**AWS:**
1. Ve a IAM Console
2. Desactiva las Access Keys comprometidas
3. Genera nuevas credenciales

### 2. Eliminar del Historial de Git

```bash
# ADVERTENCIA: Esto reescribe el historial
# Usa con cuidado

# Instalar BFG Repo-Cleaner
brew install bfg  # macOS
# o descarga de: https://rtyley.github.io/bfg-repo-cleaner/

# Eliminar archivo del historial
bfg --delete-files archivo-con-credenciales.sh

# Limpiar
git reflog expire --expire=now --all
git gc --prune=now --aggressive

# Force push (CUIDADO)
git push --force
```

### 3. Alternativa: Hacer el Repositorio Privado

Si el daño es grande:
1. Ve a Settings del repositorio en GitHub
2. Scroll hasta "Danger Zone"
3. "Change repository visibility" → Private
4. Limpia el historial
5. Vuelve a hacer público cuando esté limpio

## 📋 Checklist de Seguridad

Antes de hacer tu primer push:

- [ ] Ejecuté `./check-credentials.sh` y pasó todas las verificaciones
- [ ] Verifiqué que `install-vaultwarden-https-personal.sh` NO aparece en `git status`
- [ ] Los scripts públicos tienen placeholders, no datos reales
- [ ] No hay archivos `.pem` en el repositorio
- [ ] No hay archivos `.env` en el repositorio
- [ ] Revisé `git status` y todo se ve bien

## 🛡️ Mejores Prácticas

### 1. Usa Archivos Personales Separados

```bash
# Archivo público (se sube a GitHub)
install-vaultwarden-https.sh

# Archivo personal (NO se sube)
install-vaultwarden-https-personal.sh
```

### 2. Usa Variables de Entorno

En lugar de hardcodear credenciales:

```bash
# ❌ MAL
SMTP_PASSWORD="mi-contraseña-real"

# ✅ BIEN
SMTP_PASSWORD="${SMTP_PASSWORD:-tu-contraseña-de-app}"
```

Luego ejecuta:
```bash
export SMTP_PASSWORD="mi-contraseña-real"
./script.sh
```

### 3. Usa AWS Secrets Manager

Para producción:

```bash
# Guardar secreto
aws secretsmanager create-secret \
  --name vaultwarden/smtp-password \
  --secret-string "mi-contraseña"

# Obtener en script
SMTP_PASSWORD=$(aws secretsmanager get-secret-value \
  --secret-id vaultwarden/smtp-password \
  --query SecretString \
  --output text)
```

### 4. Revisa Antes de Commit

```bash
# Ver qué archivos se agregarán
git status

# Ver contenido de archivos staged
git diff --cached

# Si ves algo sospechoso
git reset HEAD archivo-con-problema.sh
```

## 🔐 Datos Sensibles en Este Proyecto

### Información Personal (Protegida)

Estos datos están **SOLO** en archivos `-personal.sh` (no se suben):

- Dominio: `ryozanpaku.siegfried-fs.com`
- Email: `roberto.flores@siegfried-fs.com`
- Gmail: `roberto.ciberseguridad@gmail.com`
- Contraseña de aplicación Gmail
- Contraseña Zoho (ya no se usa)

### Información Pública (Segura)

Estos datos están en archivos públicos y son **seguros**:

- Nombre: Roberto Flores
- Organización: AWS User Group Playa Vicente
- Links: https://linktr.ee/siegfried.fs
- Email de contacto público

## 📞 Reportar Problemas de Seguridad

Si encuentras credenciales expuestas en el repositorio:

1. **NO** abras un Issue público
2. Contacta directamente: https://linktr.ee/siegfried.fs
3. Describe qué encontraste y dónde
4. Espera respuesta antes de divulgar públicamente

## ✅ Resumen

| Archivo | Estado | Seguro |
|---------|--------|--------|
| `install-vaultwarden.sh` | Público | ✅ Sí |
| `install-vaultwarden-https.sh` | Público | ✅ Sí |
| `install-vaultwarden-https-personal.sh` | Privado | ✅ No se sube |
| `launch-ec2-cli.sh` | Público | ✅ Sí |
| `*.pem` | Privado | ✅ No se sube |
| `.env` | Privado | ✅ No se sube |

---

**Última actualización**: 2026-02-21  
**Mantenido por**: Roberto Flores - AWS User Group Playa Vicente

**¿Dudas sobre seguridad?** Contacta: https://linktr.ee/siegfried.fs
