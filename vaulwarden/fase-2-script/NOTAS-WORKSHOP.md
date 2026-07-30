# 📝 Notas para el Workshop

## ✅ Configuración Completada

Este proyecto está listo para el workshop con las siguientes configuraciones:

### Para el Workshop (Fase 1 y 2)
- ✅ Script HTTP funcional sin HTTPS (`install-vaultwarden.sh`)
- ✅ Compatible con Amazon Linux 2 y 2023
- ✅ No requiere dominio ni SMTP
- ✅ Instalación rápida (5-10 minutos)
- ✅ Perfecto para demostración educativa

### Para Uso Personal/Producción (Fase 2 HTTPS)
- ✅ Script HTTPS con Caddy (`install-vaultwarden-https.sh`)
- ✅ Certificados SSL automáticos con Let's Encrypt
- ✅ SMTP configurado con Gmail
- ✅ Listo para uso real

## 🎯 Plan para el Workshop

### Antes del Workshop

1. **Preparar dominio temporal**:
   - Crear subdominio en Route 53: `workshop.tudominio.com`
   - Configurar registro A apuntando a IP de EC2 del workshop
   - Después del workshop: eliminar el registro

2. **Preparar cuenta Gmail para SMTP**:
   - Crear contraseña de aplicación específica para el workshop
   - Después del workshop: revocar la contraseña de aplicación

3. **Preparar EC2**:
   - Lanzar EC2 t2.micro con Amazon Linux 2023
   - Security Group con puertos 22, 80, 443 abiertos
   - Después del workshop: terminar la instancia

### Durante el Workshop

**Fase 1 (30 min)**: Instalación manual
- Los participantes crean EC2 manualmente
- Instalan Docker y Vaultwarden paso a paso
- Acceden vía HTTP (sin SSL)

**Fase 2 (20 min)**: Automatización con script
- Presentar `install-vaultwarden.sh`
- Explicar cada sección del script
- Opcional: Mostrar versión HTTPS como "siguiente paso"

**Fase 3 (10 min)**: Infrastructure as Code
- Presentar AWS CDK
- Mostrar cómo automatizar todo con código
- Desplegar stack completo

### Después del Workshop

1. **Limpiar recursos temporales**:
   ```bash
   # Eliminar registro DNS en Route 53
   # Revocar contraseña de aplicación de Gmail
   # Terminar instancias EC2 de prueba
   ```

2. **Mantener tu instalación personal**:
   - Tu Vaultwarden personal sigue funcionando
   - Dominio: `ryozanpaku.siegfried-fs.com`
   - SMTP: Gmail configurado

## 🔒 Seguridad

### Datos Sensibles en el Repositorio

**IMPORTANTE**: Antes de hacer el repositorio público:

1. **Limpiar datos personales del script HTTPS**:
   ```bash
   # Editar fase-2-script/install-vaultwarden-https.sh
   # Cambiar:
   DOMAIN="tu-dominio.com"
   EMAIL="tu@email.com"
   SMTP_USERNAME="tu@gmail.com"
   SMTP_PASSWORD="tu-contraseña-de-app"
   ```

2. **Verificar que no hay credenciales**:
   ```bash
   grep -r "roberto" .
   grep -r "@gmail.com" .
   grep -r "siegfried-fs" .
   ```

3. **Agregar al .gitignore**:
   ```
   # Configuraciones personales
   *-personal.sh
   *.env
   ```

### Para el Workshop

- Usa credenciales temporales que puedas revocar después
- No compartas tu contraseña de aplicación de Gmail real
- Crea una contraseña de aplicación específica para el workshop

## 📋 Checklist Pre-Workshop

- [ ] Probar script HTTP en EC2 limpia
- [ ] Probar script HTTPS con dominio temporal
- [ ] Verificar que SMTP funciona con Gmail
- [ ] Preparar slides/presentación
- [ ] Documentar comandos de limpieza
- [ ] Crear contraseña de aplicación temporal de Gmail
- [ ] Configurar subdominio temporal en Route 53
- [ ] Probar todo el flujo completo
- [ ] Preparar EC2 de respaldo por si algo falla

## 📋 Checklist Post-Workshop

- [ ] Revocar contraseña de aplicación de Gmail del workshop
- [ ] Eliminar registro DNS temporal de Route 53
- [ ] Terminar instancias EC2 del workshop
- [ ] Limpiar datos personales del repositorio
- [ ] Actualizar README con feedback del workshop
- [ ] Agregar ejemplos de participantes (si aplica)

## 🎓 Lecciones Aprendidas

### SMTP
- ❌ Zoho Free NO soporta SMTP externo
- ✅ Gmail funciona perfecto con contraseñas de aplicación
- ⚠️ Quitar espacios de la contraseña de aplicación de Gmail
- ⚠️ Habilitar verificación en 2 pasos en Gmail primero

### DNS
- ⏱️ Esperar 5-10 minutos para propagación DNS
- ✅ Verificar con `nslookup` o `dig` antes de ejecutar script
- ✅ SPF debe incluir IP de EC2: `v=spf1 include:zohomail.com ip4:TU_IP_EC2 ~all`

### Caddy
- ✅ Más simple que nginx para HTTPS automático
- ✅ Renueva certificados automáticamente
- ⚠️ Requiere que DNS esté configurado correctamente
- ⚠️ Let's Encrypt tiene límite de 5 certificados/semana por dominio

### Amazon Linux
- ✅ Amazon Linux 2023 usa `yum install docker`
- ❌ Amazon Linux 2023 NO tiene `amazon-linux-extras`
- ✅ Script detecta versión automáticamente
- ✅ Caddy se instala desde binario en AL2023

## 💡 Mejoras Futuras

### Para el Repositorio
- [ ] Agregar script de limpieza automática
- [ ] Crear template de CloudFormation
- [ ] Agregar monitoreo con CloudWatch
- [ ] Documentar backup y restore
- [ ] Agregar tests automatizados

### Para el Workshop
- [ ] Video tutorial complementario
- [ ] Quiz interactivo
- [ ] Certificado de completación
- [ ] Comunidad/Discord para soporte

## 📞 Contacto

Si tienes preguntas sobre el workshop o el proyecto:
- 🔗 Todos mis links: https://linktr.ee/siegfried.fs
- 💬 AWS User Group Playa Vicente
- 🐛 GitHub Issues: [URL del repositorio]

---

**Creado por Roberto Flores para AWS User Group Playa Vicente**

**Última actualización**: 2026-02-21
**Versión del script**: 1.0
**Estado**: ✅ Listo para workshop
