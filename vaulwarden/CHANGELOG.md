# Changelog

Todos los cambios notables en este proyecto serán documentados en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/),
y este proyecto adhiere a [Semantic Versioning](https://semver.org/lang/es/).

## [1.0.0] - 2026-02-21

### 🎉 Lanzamiento Inicial

Primera versión pública del workshop de Vaultwarden en AWS EC2.

### ✨ Agregado

#### Fase 1: Despliegue Manual
- Guía completa paso a paso para despliegue manual
- Documentación con capturas de pantalla
- Referencia rápida de comandos
- Tiempo estimado: 30 minutos

#### Fase 2: Automatización con Scripts
- Script de instalación HTTP (`install-vaultwarden.sh`)
- Script de instalación HTTPS (`install-vaultwarden-https.sh`)
- Soporte para Amazon Linux 2 y Amazon Linux 2023
- Configuración SMTP con Gmail
- Documentación completa de HTTPS (HTTPS-SETUP.md)
- Guía de troubleshooting
- Tiempo estimado: 20 minutos

#### Fase 3: Infrastructure as Code
- Implementación con AWS CDK
- Stack completo en TypeScript
- Despliegue automatizado
- Tiempo estimado: 10 minutos

#### Documentación
- README principal con estructura clara
- Guía de prerequisitos
- Información de costos
- Guía de limpieza de recursos
- CONTRIBUTING.md para contribuidores
- AUTHORS.md con información del autor
- NOTAS-WORKSHOP.md para organizadores

#### Características Técnicas
- ✅ Detección automática de versión de Amazon Linux
- ✅ Instalación de Docker compatible con AL2 y AL2023
- ✅ Instalación de Caddy desde binario para AL2023
- ✅ Configuración SMTP con Gmail (Zoho Free no soportado)
- ✅ Certificados SSL automáticos con Let's Encrypt
- ✅ Logging completo con timestamps
- ✅ Manejo de errores robusto
- ✅ Verificación de DNS antes de instalación
- ✅ Headers de seguridad configurados

### 📝 Documentado

- Configuración completa de Route 53 desde cero
- Alternativas a Route 53 (Cloudflare, Namecheap, DuckDNS)
- Configuración de SMTP con Gmail paso a paso
- Explicación de por qué Zoho Free no funciona
- Solución de problemas comunes
- Mejores prácticas de seguridad

### 🔒 Seguridad

- Configuración de Security Groups
- Headers de seguridad en Caddy
- Guía de HTTPS obligatorio para producción
- Recomendaciones de 2FA
- Gestión de credenciales

### 🎓 Educativo

- Tres niveles de dificultad progresivos
- Explicaciones detalladas de cada paso
- Comparación entre métodos (manual vs automatizado)
- Recursos adicionales y enlaces
- Ejemplos prácticos

### 🤝 Comunidad

- Creado por AWS User Group Playa Vicente
- Información de contacto: https://linktr.ee/siegfried.fs
- Guía de contribución
- Código de conducta

### 🐛 Correcciones Conocidas

- Amazon Linux 2023 no soporta `amazon-linux-extras` (solucionado con detección)
- Caddy no tiene repositorio Copr para AL2023 (solucionado con instalación desde binario)
- Zoho Free no permite SMTP externo (documentado, alternativa con Gmail)

### ⚠️ Limitaciones Conocidas

- Script HTTP no incluye SSL (por diseño educativo)
- Requiere dominio para HTTPS (documentado)
- Let's Encrypt tiene límite de 5 certificados/semana (documentado)

### 📊 Estadísticas

- 3 fases de aprendizaje
- ~60 minutos de contenido total
- 2 scripts de instalación
- 1 stack de CDK
- 10+ archivos de documentación
- Soporte para 2 versiones de Amazon Linux

---

## [Unreleased]

### 🔮 Planeado para Futuras Versiones

- [ ] Soporte para otras distribuciones Linux (Ubuntu, Debian)
- [ ] Script de backup automático
- [ ] Integración con CloudWatch para monitoreo
- [ ] Template de CloudFormation
- [ ] Video tutoriales
- [ ] Traducción al inglés
- [ ] Tests automatizados
- [ ] Soporte para alta disponibilidad con ALB
- [ ] Integración con AWS Secrets Manager

### 💡 Ideas en Consideración

- Soporte para otros gestores de contraseñas
- Workshop de migración desde Bitwarden oficial
- Guía de backup y restore
- Configuración de SMTP con otros proveedores
- Integración con AWS SES

---

## Formato del Changelog

### Tipos de Cambios

- **Agregado** (`✨ Agregado`): Para nuevas funcionalidades
- **Cambiado** (`🔄 Cambiado`): Para cambios en funcionalidades existentes
- **Obsoleto** (`⚠️ Obsoleto`): Para funcionalidades que serán removidas
- **Removido** (`🗑️ Removido`): Para funcionalidades removidas
- **Corregido** (`🐛 Corregido`): Para corrección de bugs
- **Seguridad** (`🔒 Seguridad`): Para cambios de seguridad

---

## Versionado

Este proyecto usa [Semantic Versioning](https://semver.org/lang/es/):

- **MAJOR** (X.0.0): Cambios incompatibles con versiones anteriores
- **MINOR** (0.X.0): Nuevas funcionalidades compatibles
- **PATCH** (0.0.X): Correcciones de bugs compatibles

---

**Mantenido por**: Roberto Flores - AWS User Group Playa Vicente  
**Contacto**: https://linktr.ee/siegfried.fs
