# Workshop: Despliega Vaultwarden en AWS EC2

Un repositorio educativo creado por AWS User Group Playa Vicente para aprender a desplegar Vaultwarden (gestor de contraseñas auto-hospedado) en AWS EC2, desde lo manual hasta la automatización completa.

---

## Descripción

Este workshop te guiará a través de tres fases progresivas para desplegar Vaultwarden en AWS EC2. Cada fase aumenta el nivel de automatización, permitiéndote elegir tu ruta de aprendizaje según tu experiencia.

Vaultwarden es una implementación alternativa del servidor Bitwarden escrita en Rust, compatible con los clientes oficiales de Bitwarden. Es ligera, rápida y perfecta para auto-hospedaje.

---

## Elige Tu Nivel

* **Fase 1: Manual (Consola AWS)** — Tiempo: 30 minutos
  * Para principiantes en AWS.
  * Aprende los fundamentos paso a paso.
  * Usa la consola web de AWS.

* **Fase 2: Script de Automatización** — Tiempo: 20 minutos
  * Automatiza con shell scripts.
  * Usa User Data de EC2.
  * Reduce el trabajo manual.

* **Fase 3: Infrastructure as Code (CDK)** — Tiempo: 10 minutos
  * Automatización completa con código.
  * Usa AWS CDK (TypeScript).
  * Despliegue reproducible y versionable.

---

## Inicio Rápido

### Antes de Empezar

**Importante**: Este workshop utiliza recursos de AWS que forman parte de la Capa Gratuita (EC2 `t2.micro`). Revisa la sección de costos antes de comenzar.

### Selecciona Tu Método

| Método | Nivel | Tiempo | Enlace |
|---|---|---|---|
| Consola Web | Principiante | 30 min | [Fase 1: Manual](fase-1-manual/README.md) |
| Scripts | Intermedio | 20 min | [Fase 2: Automatización](fase-2-script/README.md) |
| AWS CLI | Intermedio | 10 min | [Fase 2: CLI Guide](fase-2-script/CLI-GUIDE.md) |
| CDK | Avanzado | 10 min | [Fase 3: Infrastructure as Code](fase-3-cdk/README.md) |

---

## Contenido del Repositorio

```text
vaultwarden-aws-workshop/
├── README.md                    # Este archivo
├── prerequisitos.md             # Qué necesitas antes de empezar
├── costos.md                    # Información sobre costos de AWS
├── limpieza.md                  # Cómo eliminar recursos al terminar
│
├── fase-1-manual/               # Despliegue manual paso a paso
│   ├── README.md                   # Guía completa
│   ├── comandos.md                 # Referencia rápida de comandos
│   └── imagenes/                   # Capturas de pantalla
│
├── fase-2-script/               # Automatización con scripts
│   ├── README.md                   # Guía de uso
│   ├── install-vaultwarden.sh      # Script de instalación HTTP
│   ├── install-vaultwarden-https.sh # Script de instalación HTTPS
│   ├── launch-ec2-cli.sh           # Lanzar EC2 desde CLI
│   ├── CLI-GUIDE.md                # Guía de uso de AWS CLI
│   ├── HTTPS-SETUP.md              # Guía completa de HTTPS
│   ├── NOTAS-WORKSHOP.md           # Notas para organizadores
│   └── troubleshooting.md          # Solución de problemas
│
└── fase-3-cdk/                  # Infrastructure as Code
    ├── README.md                   # Guía de CDK
    ├── bin/                        # Punto de entrada
    ├── lib/                        # Definición de infraestructura
    └── package.json                # Dependencias
```

---

## Costos Estimados

| Recurso | Costo Mensual | Free Tier |
|---|---|---|
| EC2 t2.micro | ~$8-10/mes | Incluido en 750 horas/mes (12 meses) |
| Elastic IP | Gratis (mientras esté asociada a la EC2 en vivo) | Incluido |
| Transferencia de datos | Mínima | Incluido (15 GB/mes salida) |

---

## Limpieza de Recursos

**IMPORTANTE:** No olvides eliminar los recursos de AWS cuando termines el workshop para evitar cargos inesperados. Sigue las instrucciones en [limpieza.md](limpieza.md).

---

## Consideraciones de Seguridad

Este workshop está diseñado para fines educativos y usa HTTP (sin SSL/TLS) para simplificar el aprendizaje.

**Importante:** Vaultwarden requiere HTTPS para funcionar completamente. Para uso en producción, considera:

* Configurar HTTPS con certificados SSL/TLS (ver Fase 2 - sección HTTPS).
* Usar un dominio personalizado.
* Restringir acceso SSH a IPs específicas.
* Usar AWS Secrets Manager para credenciales.
* Implementar backups automáticos.
* Mantener el sistema actualizado.

---

## Objetivos de Aprendizaje

Al completar este workshop, habrás aprendido:

* Cómo lanzar y configurar instancias EC2.
* Configuración de Security Groups y redes en AWS.
* Instalación y uso de Docker en Linux.
* Automatización con scripts de shell y User Data.
* Conceptos básicos de Infrastructure as Code con CDK.
* Mejores prácticas de seguridad en AWS.
* Gestión de costos y limpieza de recursos.

---

## Sobre el Autor

Este workshop fue creado por **Roberto Flores** para **AWS User Group Playa Vicente**.

* **Canales de la comunidad:** [AWS User Group Playa Vicente](https://www.meetup.com/aws-user-group-playa-vicente/)

---

## Licencia

Este proyecto está bajo la Licencia MIT.
