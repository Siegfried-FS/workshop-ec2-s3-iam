# 📋 Prerequisitos del Workshop

Antes de comenzar el workshop, asegúrate de tener todo lo necesario. Esta preparación te permitirá aprovechar al máximo la sesión sin interrupciones.

## ✅ Checklist Rápida

- [ ] Cuenta de AWS activa
- [ ] Tarjeta de crédito/débito válida
- [ ] Cliente SSH instalado
- [ ] Navegador web moderno
- [ ] Conocimientos básicos de línea de comandos

## 1. 🌐 Cuenta de AWS

### ¿Ya tienes una cuenta?
Si ya tienes una cuenta de AWS, puedes saltarte esta sección. Solo asegúrate de tener acceso a la consola.

### ¿No tienes cuenta? Créala aquí:

👉 **[Crear cuenta de AWS](https://portal.aws.amazon.com/billing/signup)**

**Pasos para crear tu cuenta:**

1. Visita el enlace de registro de AWS
2. Proporciona tu dirección de correo electrónico
3. Crea una contraseña segura
4. Ingresa tu información de contacto
5. **Importante**: Necesitarás una tarjeta de crédito o débito válida
6. Verifica tu identidad (llamada telefónica o SMS)
7. Selecciona el plan de soporte (elige el plan gratuito "Basic Support")

⏱️ **Tiempo estimado**: 10-15 minutos

### 💳 Sobre la Tarjeta de Crédito

AWS requiere una tarjeta de crédito para verificar tu identidad, incluso si usas el Free Tier. No te preocupes:

- ✅ Si usas recursos dentro del Free Tier, no se te cobrará
- ✅ Este workshop está diseñado para usar recursos del Free Tier cuando sea posible
- ⚠️ **Importante**: Elimina los recursos al terminar para evitar cargos (ver [limpieza.md](limpieza.md))

### 🎁 AWS Free Tier

Las cuentas nuevas de AWS incluyen 12 meses de Free Tier que cubre:

- **EC2**: 750 horas/mes de instancias t2.micro (suficiente para este workshop)
- **Transferencia de datos**: 15 GB de salida por mes
- **Elastic IP**: Gratis mientras esté asociada a una instancia en ejecución

👉 [Más información sobre AWS Free Tier](https://aws.amazon.com/free/)

## 2. 💻 Cliente SSH

Necesitarás un cliente SSH para conectarte a tu instancia EC2.

### Windows

**Opción 1: OpenSSH (Recomendado - Windows 10/11)**

Windows 10 y 11 incluyen OpenSSH por defecto. Verifica si lo tienes:

```bash
ssh -V
```

Si ves la versión de SSH, ¡estás listo!

**Opción 2: PuTTY**

Si usas una versión anterior de Windows o prefieres una interfaz gráfica:

👉 [Descargar PuTTY](https://www.putty.org/)

**Opción 3: Windows Subsystem for Linux (WSL)**

Si tienes WSL instalado, ya tienes SSH disponible.

### macOS

macOS incluye SSH por defecto. Abre la Terminal y verifica:

```bash
ssh -V
```

### Linux

La mayoría de las distribuciones de Linux incluyen SSH. Verifica con:

```bash
ssh -V
```

Si no lo tienes, instálalo:

**Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install openssh-client
```

**Fedora/RHEL:**
```bash
sudo dnf install openssh-clients
```

## 3. 🌐 Navegador Web Moderno

Necesitarás un navegador actualizado para acceder a:
- La consola de AWS
- La interfaz web de Vaultwarden

**Navegadores recomendados:**
- Google Chrome (versión reciente)
- Mozilla Firefox (versión reciente)
- Microsoft Edge (versión reciente)
- Safari (versión reciente)

## 4. 📚 Conocimientos Básicos

Este workshop asume que tienes conocimientos básicos de:

### Línea de Comandos
- Navegar entre directorios (`cd`)
- Ejecutar comandos básicos
- Copiar y pegar en la terminal

**¿Necesitas un repaso?**
- [Tutorial de línea de comandos (Linux/Mac)](https://ubuntu.com/tutorials/command-line-for-beginners)
- [Tutorial de línea de comandos (Windows)](https://www.computerhope.com/issues/chusedos.htm)

### Navegación Web
- Abrir y usar la consola de AWS
- Completar formularios web
- Navegar entre pestañas

### Conceptos Básicos (Útil pero no obligatorio)
- Qué es una dirección IP
- Qué es un puerto de red
- Concepto básico de servidor

## 5. 📝 Prerequisitos Opcionales (Solo para Fase 3)

Si planeas completar la **Fase 3 (CDK)**, necesitarás:

### Node.js (versión 14 o superior)

**Verificar si lo tienes:**
```bash
node --version
```

**Instalar Node.js:**
👉 [Descargar Node.js](https://nodejs.org/) (elige la versión LTS)

### AWS CLI

**Verificar si lo tienes:**
```bash
aws --version
```

**Instalar AWS CLI:**
👉 [Guía de instalación de AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

**Configurar AWS CLI:**
```bash
aws configure
```

Necesitarás:
- AWS Access Key ID
- AWS Secret Access Key
- Región por defecto (ej: `us-east-1`)
- Formato de salida (ej: `json`)

👉 [Cómo obtener tus credenciales de AWS](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html)

## 6. ⏰ Tiempo Requerido

Asegúrate de tener tiempo disponible:

- **Fase 1 (Manual)**: 30 minutos
- **Fase 2 (Script)**: 20 minutos
- **Fase 3 (CDK)**: 10 minutos de demostración + tiempo de práctica

**Recomendación**: Reserva al menos 1 hora para completar las Fases 1 y 2 sin prisas.

## 7. 📱 Recomendaciones Adicionales

### Toma Notas
Ten a mano un bloc de notas para guardar:
- IDs de recursos de AWS
- Direcciones IP
- Nombres de archivos de claves SSH

### Conexión a Internet Estable
Asegúrate de tener una conexión confiable durante el workshop.

### Espacio de Trabajo
Ten dos ventanas abiertas:
1. Consola de AWS
2. Terminal/línea de comandos

## ✅ Verificación Final

Antes de comenzar el workshop, verifica que tienes:

```
✅ Cuenta de AWS activa y acceso a la consola
✅ Cliente SSH funcionando (probado con ssh -V)
✅ Navegador web actualizado
✅ Tiempo disponible (mínimo 1 hora)
✅ Conexión a internet estable
✅ (Opcional) Node.js y AWS CLI para Fase 3
```

## 🚀 ¿Todo Listo?

Si completaste todos los prerequisitos, ¡estás listo para comenzar!

👉 **Siguiente paso**: Vuelve al [README principal](README.md) y elige tu fase

## ❓ ¿Problemas con los Prerequisitos?

Si tienes dificultades con algún prerequisito:

1. Revisa la documentación oficial enlazada en cada sección
2. Busca tutoriales específicos para tu sistema operativo
3. Abre un Issue en el repositorio describiendo tu problema

---

**Nota**: Es mejor preparar todo antes del día del workshop para aprovechar al máximo el tiempo de la sesión.
