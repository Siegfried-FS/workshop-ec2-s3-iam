# 📸 Capturas de Pantalla para la Fase 1

Este directorio está destinado a contener capturas de pantalla de la consola de AWS que ayudarán a los participantes del workshop a seguir los pasos visuales.

## 🎯 Capturas Requeridas

### 1. Lanzamiento de Instancia EC2

**Archivo**: `01-launch-instance.png`
- Pantalla inicial de EC2 con el botón "Launch instance"
- Muestra la ubicación del botón naranja

### 2. Selección de AMI

**Archivo**: `02-select-ami.png`
- Selección de Amazon Linux 2 AMI
- Debe mostrar el badge "Free tier eligible"

### 3. Selección de Tipo de Instancia

**Archivo**: `03-instance-type.png`
- Selección de t2.micro
- Debe mostrar las especificaciones (1 vCPU, 1 GB RAM)
- Badge de "Free tier eligible"

### 4. Creación de Par de Claves

**Archivo**: `04-key-pair.png`
- Diálogo de creación de nuevo par de claves
- Campos: nombre, tipo (RSA), formato (.pem/.ppk)

### 5. Configuración de Network Settings

**Archivo**: `05-network-settings.png`
- Sección de Network settings expandida
- Muestra VPC, Subnet, Auto-assign public IP

### 6. Configuración de Security Group

**Archivo**: `06-security-group.png`
- Creación de nuevo Security Group
- Muestra las 3 reglas de entrada:
  - SSH (puerto 22)
  - HTTP (puerto 80)
  - HTTPS (puerto 443)

### 7. Configuración de Almacenamiento

**Archivo**: `07-storage.png`
- Configuración de volumen EBS
- 8 GB, tipo gp3

### 8. Resumen y Launch

**Archivo**: `08-summary-launch.png`
- Panel de resumen a la derecha
- Botón "Launch instance" naranja

### 9. Instancia Lanzada Exitosamente

**Archivo**: `09-launch-success.png`
- Mensaje de éxito
- Enlace al Instance ID

### 10. Detalles de la Instancia

**Archivo**: `10-instance-details.png`
- Vista de detalles de la instancia
- Muestra Instance ID, Public IPv4 address, Instance state

### 11. Botón Connect

**Archivo**: `11-connect-button.png`
- Ubicación del botón "Connect" en la consola
- Instancia seleccionada

### 12. Instrucciones de SSH

**Archivo**: `12-ssh-instructions.png`
- Pestaña "SSH client" en el diálogo de conexión
- Comando de ejemplo para SSH

### 13. Interfaz de Vaultwarden

**Archivo**: `13-vaultwarden-home.png`
- Página de inicio de Vaultwarden en el navegador
- Formulario de login/registro

### 14. Crear Cuenta en Vaultwarden

**Archivo**: `14-create-account.png`
- Formulario de creación de cuenta
- Campos: email, nombre, contraseña

### 15. Dashboard de Vaultwarden

**Archivo**: `15-vaultwarden-dashboard.png`
- Vista del dashboard después de iniciar sesión
- Muestra la interfaz principal

## 📝 Instrucciones para Capturar

### Herramientas Recomendadas

**Windows:**
- Snipping Tool (Win + Shift + S)
- Snip & Sketch

**Mac:**
- Cmd + Shift + 4 (selección de área)
- Cmd + Shift + 3 (pantalla completa)

**Linux:**
- Gnome Screenshot
- Flameshot
- Spectacle (KDE)

### Mejores Prácticas

1. **Resolución**: Captura en resolución alta (mínimo 1920x1080)
2. **Formato**: PNG para mejor calidad
3. **Contenido**: Asegúrate de que el texto sea legible
4. **Privacidad**: Oculta información sensible:
   - Account IDs
   - IPs privadas (si es necesario)
   - Nombres de usuario personales
5. **Consistencia**: Usa el mismo tema de consola AWS (claro u oscuro)
6. **Anotaciones**: Considera agregar flechas o resaltados para elementos importantes

### Herramientas de Anotación

- **Windows**: Paint, Paint 3D
- **Mac**: Preview (Markup tools)
- **Linux**: GIMP, Krita
- **Multiplataforma**: 
  - [Greenshot](https://getgreenshot.org/)
  - [ShareX](https://getsharex.com/) (Windows)
  - [Flameshot](https://flameshot.org/) (Linux)

## 🎨 Formato de Nombres

Usa el formato: `##-descripcion-corta.png`

Ejemplos:
- `01-launch-instance.png`
- `02-select-ami.png`
- `06-security-group.png`

## 📐 Dimensiones Recomendadas

- **Ancho**: 1200-1920 px
- **Alto**: Variable según contenido
- **Formato**: PNG
- **Compresión**: Moderada (para balance entre calidad y tamaño)

## 🔄 Actualización de Capturas

Si AWS actualiza su interfaz, las capturas deberán actualizarse. Mantén un registro de:
- Fecha de captura
- Versión de la consola AWS
- Región usada (preferiblemente us-east-1)

## 📦 Contribuir Capturas

Si deseas contribuir capturas de pantalla:

1. Sigue el formato de nombres especificado
2. Asegúrate de que no contengan información sensible
3. Optimiza el tamaño del archivo (usa herramientas como TinyPNG)
4. Envía un Pull Request con las imágenes

## ⚠️ Nota Importante

Las capturas de pantalla son opcionales pero altamente recomendadas para mejorar la experiencia del workshop. Si no tienes las capturas, los participantes aún pueden seguir las instrucciones textuales detalladas en el README.md.

---

**Estado actual**: 📝 Pendiente - Las capturas de pantalla serán agregadas por el instructor del workshop

**Contribuciones**: ¡Bienvenidas! Si tienes capturas de pantalla de calidad, por favor compártelas.
