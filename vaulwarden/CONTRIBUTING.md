# 🤝 Guía de Contribución

¡Gracias por tu interés en contribuir a este proyecto! Este workshop fue creado por **AWS User Group Playa Vicente** para la comunidad, y valoramos todas las contribuciones.

## 📋 Cómo Contribuir

### 1. Reportar Problemas

Si encuentras un error o tienes una sugerencia:

1. Busca en los [Issues existentes](../../issues) para ver si ya fue reportado
2. Si no existe, crea un nuevo Issue con:
   - **Título descriptivo**: Ej: "Error en script de instalación en Amazon Linux 2023"
   - **Descripción detallada**: Qué esperabas vs qué obtuviste
   - **Pasos para reproducir**: Cómo llegaste al error
   - **Logs o capturas**: Si es posible, incluye evidencia
   - **Entorno**: Versión de Amazon Linux, región de AWS, etc.

### 2. Proponer Mejoras

¿Tienes una idea para mejorar el workshop?

1. Abre un Issue con la etiqueta `enhancement`
2. Describe tu propuesta:
   - ¿Qué problema resuelve?
   - ¿Cómo beneficia a los usuarios?
   - ¿Tienes un ejemplo o implementación en mente?

### 3. Enviar Pull Requests

#### Antes de empezar

1. Haz un Fork del repositorio
2. Clona tu fork localmente
3. Crea una rama para tu cambio:
   ```bash
   git checkout -b feature/mi-mejora
   # o
   git checkout -b fix/correccion-bug
   ```

#### Haciendo cambios

1. **Mantén el estilo**: Sigue el formato y estilo existente
2. **Documenta**: Actualiza README.md si es necesario
3. **Prueba**: Verifica que tus cambios funcionan
4. **Commits claros**: Usa mensajes descriptivos

Ejemplo de buenos commits:
```
✅ Agrega soporte para Amazon Linux 2023
✅ Corrige error en detección de IP pública
✅ Actualiza documentación de HTTPS
```

Ejemplo de malos commits:
```
❌ fix
❌ update
❌ cambios varios
```

#### Enviando el Pull Request

1. Push a tu fork:
   ```bash
   git push origin feature/mi-mejora
   ```

2. Abre un Pull Request en GitHub

3. Describe tus cambios:
   - **Qué cambia**: Resumen de los cambios
   - **Por qué**: Razón del cambio
   - **Cómo probaste**: Pasos de verificación
   - **Screenshots**: Si aplica

4. Espera el review y responde a comentarios

## 📝 Estándares de Código

### Scripts de Shell

- Usa `#!/bin/bash` al inicio
- Incluye comentarios descriptivos
- Maneja errores con `|| error_exit`
- Usa logging con timestamps
- Verifica prerequisitos al inicio

Ejemplo:
```bash
#!/bin/bash

# Función para logging
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Función para errores
error_exit() {
    log "ERROR: $1"
    exit 1
}

# Verificar prerequisitos
command -v docker >/dev/null 2>&1 || error_exit "Docker no está instalado"
```

### Documentación

- Usa Markdown para toda la documentación
- Incluye emojis para mejor legibilidad (📋 ✅ ⚠️ 🚀)
- Estructura clara con headers
- Ejemplos de código con syntax highlighting
- Links a recursos externos cuando sea relevante

### Commits

Usa [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` Nueva funcionalidad
- `fix:` Corrección de bug
- `docs:` Cambios en documentación
- `style:` Formato, espacios, etc.
- `refactor:` Refactorización de código
- `test:` Agregar o modificar tests
- `chore:` Tareas de mantenimiento

Ejemplos:
```
feat: agrega script de instalación con HTTPS
fix: corrige detección de Amazon Linux 2023
docs: actualiza guía de Route 53
```

## 🔍 Proceso de Review

1. **Revisión automática**: GitHub Actions verifica formato
2. **Revisión manual**: Un maintainer revisa el código
3. **Feedback**: Puede haber comentarios o solicitudes de cambios
4. **Aprobación**: Una vez aprobado, se hace merge
5. **Agradecimiento**: ¡Tu contribución es valorada! 🎉

## 🎯 Áreas de Contribución

### Prioridad Alta

- 🐛 Corrección de bugs reportados
- 📖 Mejoras en documentación
- 🔒 Mejoras de seguridad
- 🌐 Traducciones (inglés, otros idiomas)

### Prioridad Media

- ✨ Nuevas funcionalidades
- 🎨 Mejoras de UX en documentación
- 📊 Ejemplos adicionales
- 🧪 Tests automatizados

### Ideas Bienvenidas

- 💡 Soporte para otros proveedores cloud
- 🔧 Scripts de troubleshooting
- 📹 Videos tutoriales
- 🎓 Ejercicios adicionales

## ❓ Preguntas Frecuentes

### ¿Puedo contribuir si soy principiante?

¡Absolutamente! Contribuciones de todos los niveles son bienvenidas:
- Corregir typos en documentación
- Mejorar explicaciones
- Reportar problemas que encuentres
- Sugerir mejoras en la claridad

### ¿Necesito conocer AWS para contribuir?

No necesariamente. Puedes contribuir en:
- Documentación
- Scripts de shell
- Mejoras de formato
- Traducciones

### ¿Cuánto tiempo toma el review?

Intentamos revisar PRs en 2-3 días hábiles. Si es urgente, menciona en el PR.

### ¿Qué pasa si mi PR no es aceptado?

No te desanimes. Recibirás feedback constructivo sobre:
- Qué se puede mejorar
- Por qué no se aceptó
- Alternativas posibles

## 📞 Contacto

¿Tienes preguntas sobre cómo contribuir?

- 🔗 Contacto: https://linktr.ee/siegfried.fs
- 💬 AWS User Group Playa Vicente
- 📧 Abre un Issue con la etiqueta `question`

## 🙏 Agradecimientos

Gracias a todos los que han contribuido a este proyecto:

- Reportando bugs
- Sugiriendo mejoras
- Compartiendo el workshop
- Participando en la comunidad

**Tu contribución hace la diferencia** ❤️

---

## 📜 Código de Conducta

Este proyecto sigue un código de conducta simple:

1. **Sé respetuoso**: Trata a todos con respeto
2. **Sé constructivo**: Críticas constructivas, no destructivas
3. **Sé inclusivo**: Todos son bienvenidos
4. **Sé paciente**: Recuerda que todos estamos aprendiendo

Violaciones a este código pueden resultar en la eliminación de comentarios o bloqueo de usuarios.

---

**¡Gracias por contribuir a AWS User Group Playa Vicente!** 🚀

