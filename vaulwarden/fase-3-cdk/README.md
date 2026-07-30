# ⚙️ Fase 3: Infrastructure as Code con AWS CDK

⏱️ **Tiempo estimado**: 10 minutos (demostración) + tiempo de práctica  
🎯 **Nivel**: Avanzado  
📋 **Prerequisitos**: Node.js, AWS CLI configurado, conocimientos de TypeScript

⚠️ **Nota**: Esta fase es opcional y está diseñada para practicar después del workshop.

## 📖 Introducción

En las fases anteriores aprendiste a desplegar Vaultwarden manualmente y con scripts. Ahora daremos el siguiente paso: **Infrastructure as Code (IaC)** usando AWS CDK.

### ¿Qué es Infrastructure as Code?

Infrastructure as Code es la práctica de gestionar y aprovisionar infraestructura mediante código en lugar de procesos manuales.

**Beneficios**:
- ✅ **Versionable**: Usa Git para controlar cambios
- ✅ **Repetible**: Despliega la misma infraestructura múltiples veces
- ✅ **Documentado**: El código es la documentación
- ✅ **Testeable**: Puedes escribir pruebas para tu infraestructura
- ✅ **Colaborativo**: Múltiples personas pueden trabajar en el mismo código

### ¿Qué es AWS CDK?

AWS Cloud Development Kit (CDK) es un framework de desarrollo de software para definir infraestructura de nube usando lenguajes de programación familiares.

**Ventajas de CDK**:
- 🔷 Usa TypeScript, Python, Java, C#, o Go
- 🔷 Abstracciones de alto nivel (constructs)
- 🔷 Reutilización de código
- 🔷 Autocompletado y validación en el IDE
- 🔷 Genera templates de CloudFormation automáticamente

### Comparación de Métodos

| Característica | Manual | Script | CDK |
|----------------|--------|--------|-----|
| Tiempo de setup | 30 min | 5 min | 2 min |
| Repetibilidad | Baja | Media | Alta |
| Versionable | No | Parcial | Sí |
| Testeable | No | Limitado | Sí |
| Gestión de estado | Manual | Manual | Automática |
| Rollback | Manual | Manual | Automático |
| Complejidad | Baja | Media | Alta |

---

## 📋 Prerequisitos

### 1. Node.js (versión 14 o superior)

```bash
# Verificar instalación
node --version

# Debe mostrar v14.x.x o superior
```

**Instalar Node.js**:
👉 [https://nodejs.org/](https://nodejs.org/) (descarga la versión LTS)

### 2. AWS CLI Configurado

```bash
# Verificar instalación
aws --version

# Configurar credenciales
aws configure
```

Necesitarás:
- AWS Access Key ID
- AWS Secret Access Key
- Región por defecto (ej: `us-east-1`)
- Formato de salida (ej: `json`)

**Instalar AWS CLI**:
👉 [Guía de instalación](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

### 3. AWS CDK CLI

```bash
# Instalar CDK globalmente
npm install -g aws-cdk

# Verificar instalación
cdk --version
```

### 4. Par de Claves SSH

Antes de desplegar, crea un par de claves llamado `vaultwarden-key-cdk`:

1. Ve a EC2 → Key Pairs en la consola de AWS
2. Haz clic en "Create key pair"
3. Nombre: `vaultwarden-key-cdk`
4. Tipo: RSA
5. Formato: .pem (Mac/Linux) o .ppk (Windows)
6. Descarga y guarda el archivo

---

## 🚀 Inicio Rápido

### Paso 1: Instalar Dependencias

```bash
# Navegar al directorio de CDK
cd fase-3-cdk

# Instalar dependencias de Node.js
npm install
```

### Paso 2: Bootstrap CDK (Solo la Primera Vez)

Bootstrap prepara tu cuenta de AWS para usar CDK:

```bash
cdk bootstrap
```

Esto crea recursos necesarios en tu cuenta (bucket S3, roles IAM, etc.).

**Nota**: Solo necesitas hacer esto una vez por cuenta/región.

### Paso 3: Compilar el Código TypeScript

```bash
npm run build
```

### Paso 4: Ver el Template de CloudFormation (Opcional)

```bash
cdk synth
```

Esto genera el template de CloudFormation que CDK creará.

### Paso 5: Ver los Cambios Antes de Desplegar

```bash
cdk diff
```

Muestra qué recursos se crearán, modificarán o eliminarán.

### Paso 6: Desplegar

```bash
cdk deploy
```

CDK te mostrará los cambios y pedirá confirmación. Escribe `y` y presiona Enter.

⏱️ **Tiempo de despliegue**: 3-5 minutos

### Paso 7: Ver los Outputs

Después del despliegue, verás información importante:

```
Outputs:
VaultwardenStack.InstanceId = i-1234567890abcdef0
VaultwardenStack.PublicIP = 54.123.45.67
VaultwardenStack.VaultwardenURL = http://54.123.45.67
VaultwardenStack.SSHCommand = ssh -i ~/.ssh/vaultwarden-key-cdk.pem ec2-user@54.123.45.67
```

### Paso 8: Acceder a Vaultwarden

Abre tu navegador y ve a la URL mostrada en los outputs:

```
http://TU_IP_PUBLICA
```

---

## 📁 Estructura del Proyecto

```
fase-3-cdk/
├── bin/
│   └── vaultwarden-stack.ts    # Punto de entrada de la aplicación
├── lib/
│   └── vaultwarden-stack.ts    # Definición del stack (infraestructura)
├── node_modules/               # Dependencias (generado)
├── cdk.out/                    # Templates generados (generado)
├── package.json                # Dependencias y scripts
├── tsconfig.json               # Configuración de TypeScript
├── cdk.json                    # Configuración de CDK
└── README.md                   # Este archivo
```

### Archivos Principales

#### `bin/vaultwarden-stack.ts`
Punto de entrada de la aplicación CDK. Crea la app y el stack.

#### `lib/vaultwarden-stack.ts`
Define toda la infraestructura:
- VPC (usa la VPC por defecto)
- Security Group (puertos 22, 80, 443)
- Instancia EC2 (Amazon Linux 2, t2.micro)
- Elastic IP (IP pública estática)
- Volumen EBS persistente (8 GB)
- User Data (script de instalación)

---

## 🔍 Entendiendo el Código

### Crear un Security Group

```typescript
const securityGroup = new ec2.SecurityGroup(this, 'VaultwardenSecurityGroup', {
  vpc,
  description: 'Security Group para Vaultwarden',
  allowAllOutbound: true,
});

// Agregar reglas de entrada
securityGroup.addIngressRule(
  ec2.Peer.anyIpv4(),
  ec2.Port.tcp(22),
  'Permitir SSH'
);
```

### Crear una Instancia EC2

```typescript
const instance = new ec2.Instance(this, 'VaultwardenInstance', {
  instanceType: ec2.InstanceType.of(
    ec2.InstanceClass.T2,
    ec2.InstanceSize.MICRO
  ),
  machineImage: ec2.MachineImage.latestAmazonLinux2(),
  vpc,
  securityGroup,
  keyName: 'vaultwarden-key-cdk',
  userData: ec2.UserData.forLinux(),
});
```

### Crear una Elastic IP

```typescript
const eip = new ec2.CfnEIP(this, 'VaultwardenEIP', {
  domain: 'vpc',
});

new ec2.CfnEIPAssociation(this, 'EIPAssociation', {
  eip: eip.ref,
  instanceId: instance.instanceId,
});
```

### Definir Outputs

```typescript
new cdk.CfnOutput(this, 'PublicIP', {
  value: eip.ref,
  description: 'IP pública de Vaultwarden',
});
```

---

## 🛠️ Comandos Útiles

### Desarrollo

```bash
# Compilar TypeScript
npm run build

# Compilar en modo watch (recompila automáticamente)
npm run watch

# Ver el template de CloudFormation
cdk synth

# Ver diferencias con el stack desplegado
cdk diff
```

### Despliegue

```bash
# Desplegar el stack
cdk deploy

# Desplegar sin pedir confirmación
cdk deploy --require-approval never

# Desplegar con outputs en formato JSON
cdk deploy --outputs-file outputs.json
```

### Gestión

```bash
# Listar todos los stacks
cdk list

# Ver información del stack
cdk context

# Limpiar archivos generados
rm -rf cdk.out node_modules
npm install
```

### Eliminación

```bash
# Eliminar el stack (destruir toda la infraestructura)
cdk destroy

# Eliminar sin pedir confirmación
cdk destroy --force
```

---

## 🔄 Actualizar la Infraestructura

### Modificar el Código

1. Edita `lib/vaultwarden-stack.ts`
2. Por ejemplo, cambia el tipo de instancia:

```typescript
instanceType: ec2.InstanceType.of(
  ec2.InstanceClass.T3,  // Cambiar de T2 a T3
  ec2.InstanceSize.SMALL // Cambiar de MICRO a SMALL
),
```

### Ver los Cambios

```bash
npm run build
cdk diff
```

CDK te mostrará exactamente qué cambiará.

### Aplicar los Cambios

```bash
cdk deploy
```

CDK actualizará solo los recursos que cambiaron.

---

## 🧪 Testing (Opcional)

CDK permite escribir pruebas para tu infraestructura.

### Instalar Dependencias de Testing

```bash
npm install --save-dev jest @types/jest ts-jest
```

### Ejemplo de Prueba

```typescript
import * as cdk from 'aws-cdk-lib';
import { Template } from 'aws-cdk-lib/assertions';
import { VaultwardenStack } from '../lib/vaultwarden-stack';

test('Security Group Created', () => {
  const app = new cdk.App();
  const stack = new VaultwardenStack(app, 'TestStack');
  const template = Template.fromStack(stack);

  // Verificar que se crea un Security Group
  template.resourceCountIs('AWS::EC2::SecurityGroup', 1);
});
```

### Ejecutar Pruebas

```bash
npm test
```

---

## 🔒 Volumen EBS Persistente

El código CDK configura el volumen EBS para que **NO se elimine** cuando terminas la instancia:

```typescript
blockDevices: [
  {
    deviceName: '/dev/xvda',
    volume: ec2.BlockDeviceVolume.ebs(8, {
      deleteOnTermination: false, // ¡Importante!
      encrypted: true,
    }),
  },
],
```

Esto significa que tus datos de Vaultwarden se conservarán incluso si eliminas la instancia.

### Recuperar Datos

Si terminas la instancia pero quieres recuperar los datos:

1. Ve a EC2 → Volumes
2. Encuentra el volumen (busca por tags)
3. Crea una nueva instancia
4. Adjunta el volumen a la nueva instancia
5. Monta el volumen y accede a `/vw-data/`

---

## 🎯 Ventajas de CDK vs Métodos Anteriores

### vs Manual (Fase 1)

| CDK | Manual |
|-----|--------|
| 2 minutos de despliegue | 30 minutos de trabajo |
| Repetible infinitamente | Cada vez es manual |
| Versionable con Git | Difícil de documentar |
| Rollback automático | Rollback manual |

### vs Script (Fase 2)

| CDK | Script |
|-----|--------|
| Gestiona toda la infraestructura | Solo configura la instancia |
| Actualiza recursos existentes | Requiere recrear instancia |
| Elimina recursos automáticamente | Limpieza manual |
| Detecta cambios (drift detection) | Sin detección de cambios |

---

## 🌟 Casos de Uso Avanzados

### 1. Múltiples Entornos

Crea stacks separados para desarrollo, staging y producción:

```typescript
new VaultwardenStack(app, 'VaultwardenDev', {
  env: { region: 'us-east-1' },
  tags: { Environment: 'Development' },
});

new VaultwardenStack(app, 'VaultwardenProd', {
  env: { region: 'us-west-2' },
  tags: { Environment: 'Production' },
});
```

### 2. Configuración Parametrizada

Usa context para parametrizar el stack:

```bash
cdk deploy -c instanceType=t3.small -c volumeSize=16
```

```typescript
const instanceType = this.node.tryGetContext('instanceType') || 't2.micro';
const volumeSize = this.node.tryGetContext('volumeSize') || 8;
```

### 3. Agregar Dominio Personalizado

Integra Route 53 para usar un dominio:

```typescript
import * as route53 from 'aws-cdk-lib/aws-route53';
import * as targets from 'aws-cdk-lib/aws-route53-targets';

const zone = route53.HostedZone.fromLookup(this, 'Zone', {
  domainName: 'tudominio.com',
});

new route53.ARecord(this, 'VaultwardenRecord', {
  zone,
  recordName: 'vault',
  target: route53.RecordTarget.fromIpAddresses(eip.ref),
});
```

### 4. Agregar Backups Automáticos

Usa AWS Backup para backups automáticos:

```typescript
import * as backup from 'aws-cdk-lib/aws-backup';

const plan = new backup.BackupPlan(this, 'BackupPlan', {
  backupPlanName: 'VaultwardenBackup',
});

plan.addSelection('Selection', {
  resources: [
    backup.BackupResource.fromEc2Instance(instance),
  ],
});
```

---

## 📚 Recursos Adicionales

### Documentación Oficial

- [AWS CDK Documentation](https://docs.aws.amazon.com/cdk/)
- [CDK API Reference](https://docs.aws.amazon.com/cdk/api/v2/)
- [CDK Workshop](https://cdkworkshop.com/)
- [CDK Examples](https://github.com/aws-samples/aws-cdk-examples)

### Tutoriales

- [Getting Started with CDK](https://docs.aws.amazon.com/cdk/v2/guide/getting_started.html)
- [CDK Best Practices](https://docs.aws.amazon.com/cdk/v2/guide/best-practices.html)
- [CDK Patterns](https://cdkpatterns.com/)

### Comunidad

- [CDK GitHub](https://github.com/aws/aws-cdk)
- [CDK Slack](https://cdk.dev/)
- [AWS Forums](https://forums.aws.amazon.com/)

---

## ❗ Solución de Problemas

### Error: "CDK not found"

```bash
# Instalar CDK globalmente
npm install -g aws-cdk
```

### Error: "Need to perform AWS calls for account..."

```bash
# Configurar AWS CLI
aws configure

# Verificar credenciales
aws sts get-caller-identity
```

### Error: "This stack uses assets..."

```bash
# Bootstrap CDK
cdk bootstrap
```

### Error: "Key pair does not exist"

Crea el par de claves `vaultwarden-key-cdk` en la consola de EC2.

### Error: "No default VPC found"

Si no tienes una VPC por defecto, crea una o modifica el código para crear una VPC personalizada.

---

## 🧹 Limpieza

### Eliminar Toda la Infraestructura

```bash
cdk destroy
```

Esto eliminará:
- ✅ Instancia EC2
- ✅ Elastic IP
- ✅ Security Group
- ⚠️ **NO** eliminará el volumen EBS (por diseño)

### Eliminar el Volumen EBS Manualmente

1. Ve a EC2 → Volumes
2. Encuentra el volumen (busca por tags: `Vaultwarden-CDK`)
3. Selecciónalo
4. Actions → Delete volume

### Limpiar Archivos Locales

```bash
# Eliminar archivos generados
rm -rf cdk.out node_modules

# Reinstalar si es necesario
npm install
```

---

## 💰 Costos

Los costos son los mismos que en las fases anteriores:

- **EC2 t2.micro**: ~$8-10/mes (gratis en Free Tier)
- **Elastic IP**: Gratis mientras esté asociada
- **EBS 8GB**: ~$0.80/mes (gratis en Free Tier)

**Importante**: No olvides ejecutar `cdk destroy` cuando termines.

---

## 🎓 ¿Qué Aprendiste?

Al completar esta fase, ahora sabes:

- ✅ Qué es Infrastructure as Code
- ✅ Cómo usar AWS CDK
- ✅ Cómo definir infraestructura con TypeScript
- ✅ Cómo desplegar y actualizar stacks
- ✅ Cómo gestionar el ciclo de vida de recursos
- ✅ Ventajas de IaC vs métodos manuales

---

## 🎯 Próximos Pasos

### Practica Más

1. **Modifica el código**:
   - Cambia el tipo de instancia
   - Agrega más reglas al Security Group
   - Cambia el tamaño del volumen

2. **Agrega funcionalidades**:
   - Dominio personalizado con Route 53
   - Certificado SSL/TLS con ACM
   - Backups automáticos con AWS Backup
   - Monitoreo con CloudWatch

3. **Aprende más CDK**:
   - Crea múltiples stacks
   - Usa CDK Pipelines para CI/CD
   - Escribe pruebas para tu infraestructura

### Comparte tu Experiencia

- Presenta en tu AWS User Group
- Escribe un blog post
- Contribuye al repositorio

---

## 🤝 Contribuciones

¿Mejoras para el código CDK? ¡Las contribuciones son bienvenidas!

1. Fork el repositorio
2. Crea una rama con tu mejora
3. Envía un Pull Request

---

**¿Completaste las 3 fases?** 🎉

¡Felicidades! Ahora dominas tres métodos para desplegar infraestructura en AWS:
1. Manual (entendimiento profundo)
2. Scripts (automatización básica)
3. CDK (Infrastructure as Code profesional)

**No olvides limpiar los recursos**: [limpieza.md](../limpieza.md)
