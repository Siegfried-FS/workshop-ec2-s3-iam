# 🧹 Guía de Limpieza de Recursos

⚠️ **MUY IMPORTANTE**: No olvides eliminar los recursos de AWS cuando termines el workshop para evitar cargos inesperados.

Esta guía te ayudará a eliminar todos los recursos creados durante el workshop, independientemente del método que hayas usado.

---

## 📋 Tabla de Contenidos

1. [¿Por qué es importante limpiar?](#por-qué-es-importante-limpiar)
2. [Limpieza por Fase](#limpieza-por-fase)
3. [Verificación Final](#verificación-final)
4. [Recursos que Generan Costos](#recursos-que-generan-costos)
5. [Checklist de Limpieza](#checklist-de-limpieza)

---

## ⚠️ ¿Por Qué es Importante Limpiar?

### Costos Continuos

Algunos recursos de AWS generan costos mientras existan, incluso si no los estás usando:

| Recurso | Costo si NO se elimina |
|---------|------------------------|
| Instancia EC2 corriendo | ~$0.28/día (~$8.50/mes) |
| Elastic IP no asociada | ~$0.12/día (~$3.60/mes) |
| Volumen EBS | ~$0.80/mes |
| Snapshots EBS | $0.05/GB/mes |

### Límites de Cuenta

AWS tiene límites en el número de recursos que puedes tener. Eliminar recursos no usados libera espacio para futuros proyectos.

### Buenas Prácticas

Limpiar después de cada experimento es una buena práctica de ingeniería y gestión de costos.

---

## 🗑️ Limpieza por Fase

Elige el método según cómo desplegaste Vaultwarden:

### Opción 1: Limpieza Manual (Fase 1 y 2)

Si desplegaste usando la consola de AWS o el script de User Data, sigue estos pasos:

#### Paso 1: Terminar la Instancia EC2

1. Ve a [EC2 Console](https://console.aws.amazon.com/ec2/)
2. En el menú izquierdo, haz clic en **"Instances"**
3. Selecciona tu instancia (busca por nombre: `Vaultwarden-Workshop` o `Vaultwarden-Automated`)
4. Haz clic en **"Instance state"** → **"Terminate instance"**
5. Confirma haciendo clic en **"Terminate"**

⏱️ **Tiempo**: 1-2 minutos

**Importante**: Terminar una instancia es permanente. Asegúrate de haber guardado cualquier dato importante.

#### Paso 2: Liberar la Elastic IP

⚠️ **Crítico**: Si no liberas la Elastic IP, se te cobrará $3.60/mes

1. En EC2 Console, ve a **"Elastic IPs"** (menú izquierdo)
2. Selecciona tu Elastic IP
3. Haz clic en **"Actions"** → **"Release Elastic IP addresses"**
4. Confirma haciendo clic en **"Release"**

⏱️ **Tiempo**: 30 segundos

#### Paso 3: Eliminar Volúmenes EBS Huérfanos (Opcional)

Si configuraste el volumen para que NO se elimine automáticamente:

1. Ve a **"Volumes"** (menú izquierdo en EC2)
2. Busca volúmenes con estado **"available"** (no attached)
3. Selecciona el volumen
4. Haz clic en **"Actions"** → **"Delete volume"**
5. Confirma

⏱️ **Tiempo**: 30 segundos

**Nota**: Si el volumen se configuró con `deleteOnTermination: true`, se eliminará automáticamente con la instancia.

#### Paso 4: Eliminar Security Group (Opcional)

Si creaste un Security Group personalizado:

1. Ve a **"Security Groups"** (menú izquierdo en EC2)
2. Busca tu Security Group (ej: `vaultwarden-sg`)
3. Selecciónalo
4. Haz clic en **"Actions"** → **"Delete security group"**
5. Confirma

⚠️ **Nota**: No puedes eliminar un Security Group si está en uso. Asegúrate de haber terminado la instancia primero.

#### Paso 5: Eliminar Par de Claves (Opcional)

Si creaste un par de claves específico para el workshop:

1. Ve a **"Key Pairs"** (menú izquierdo en EC2)
2. Selecciona tu par de claves (ej: `vaultwarden-key`)
3. Haz clic en **"Actions"** → **"Delete"**
4. Confirma

**Importante**: También elimina el archivo `.pem` de tu computadora si ya no lo necesitas.

---

### Opción 2: Limpieza con CDK (Fase 3)

Si desplegaste usando AWS CDK, la limpieza es mucho más simple:

#### Comando de Limpieza

```bash
# Navegar al directorio de CDK
cd fase-3-cdk

# Eliminar el stack completo
cdk destroy
```

CDK te mostrará todos los recursos que se eliminarán:

```
Are you sure you want to delete: VaultwardenStack (y/n)?
```

Escribe `y` y presiona Enter.

⏱️ **Tiempo**: 2-3 minutos

#### Limpieza Forzada (Sin Confirmación)

```bash
cdk destroy --force
```

#### Verificar Eliminación

```bash
# Listar stacks (no debería mostrar VaultwardenStack)
cdk list
```

#### Limpieza del Volumen EBS

⚠️ **Importante**: El volumen EBS está configurado para NO eliminarse automáticamente.

Después de `cdk destroy`, elimina el volumen manualmente:

1. Ve a EC2 → Volumes
2. Busca el volumen (tags: `Vaultwarden-CDK`)
3. Selecciónalo
4. Actions → Delete volume

---

## ✅ Verificación Final

Después de limpiar, verifica que no queden recursos activos:

### Checklist de Verificación

```bash
# Verificar instancias EC2
aws ec2 describe-instances \
  --filters "Name=instance-state-name,Values=running,stopped" \
  --query "Reservations[].Instances[].{ID:InstanceId,Name:Tags[?Key=='Name']|[0].Value,State:State.Name}"

# Verificar Elastic IPs
aws ec2 describe-addresses \
  --query "Addresses[].{IP:PublicIp,InstanceId:InstanceId,AllocationId:AllocationId}"

# Verificar volúmenes disponibles (no attached)
aws ec2 describe-volumes \
  --filters "Name=status,Values=available" \
  --query "Volumes[].{ID:VolumeId,Size:Size,State:State}"

# Verificar Security Groups personalizados
aws ec2 describe-security-groups \
  --filters "Name=group-name,Values=vaultwarden*" \
  --query "SecurityGroups[].{Name:GroupName,ID:GroupId}"
```

### Verificación en la Consola

1. **EC2 Dashboard**:
   - Instances: 0 running
   - Elastic IPs: 0 allocated
   - Volumes: Solo volúmenes en uso

2. **Billing Dashboard**:
   - Ve a [Billing Console](https://console.aws.amazon.com/billing/)
   - Revisa "Bills" para el mes actual
   - Verifica que no haya cargos inesperados

---

## 💰 Recursos que Generan Costos

### Recursos que SIEMPRE Generan Costos

| Recurso | Costo | Cómo Evitar |
|---------|-------|-------------|
| Instancia EC2 corriendo | $0.0116/hora | Terminar la instancia |
| Elastic IP no asociada | $0.005/hora | Liberar la Elastic IP |
| Volumen EBS | $0.10/GB/mes | Eliminar volúmenes no usados |
| Snapshots EBS | $0.05/GB/mes | Eliminar snapshots antiguos |

### Recursos Cubiertos por Free Tier

Si tu cuenta es elegible para Free Tier (primeros 12 meses):

- ✅ 750 horas/mes de EC2 t2.micro
- ✅ 30 GB de almacenamiento EBS
- ✅ Elastic IP gratis si está asociada

**Después de 12 meses**, estos recursos empiezan a generar costos.

---

## 📝 Checklist de Limpieza

Usa esta checklist para asegurarte de que eliminaste todo:

### Limpieza Manual (Fase 1 y 2)

```
□ Terminar instancia EC2
□ Liberar Elastic IP
□ Eliminar volúmenes EBS huérfanos
□ Eliminar Security Group personalizado (opcional)
□ Eliminar par de claves (opcional)
□ Eliminar archivo .pem local (opcional)
□ Verificar en EC2 Dashboard que no quedan recursos
```

### Limpieza con CDK (Fase 3)

```
□ Ejecutar cdk destroy
□ Confirmar eliminación
□ Eliminar volumen EBS manualmente
□ Verificar con cdk list que el stack se eliminó
□ Verificar en EC2 Dashboard que no quedan recursos
```

### Verificación Final

```
□ No hay instancias corriendo o detenidas
□ No hay Elastic IPs asignadas
□ No hay volúmenes disponibles (available)
□ No hay Security Groups personalizados
□ Revisar factura de AWS
□ Configurar alarma de facturación (para el futuro)
```

---

## 🔔 Configurar Alarmas para el Futuro

Para evitar sorpresas en el futuro, configura alarmas de facturación:

### Paso 1: Habilitar Alertas de Facturación

1. Ve a [Billing Preferences](https://console.aws.amazon.com/billing/home#/preferences)
2. Marca **"Receive Billing Alerts"**
3. Guarda las preferencias

### Paso 2: Crear Alarma en CloudWatch

1. Ve a [CloudWatch Console](https://console.aws.amazon.com/cloudwatch/)
2. Selecciona **"Alarms"** → **"Create alarm"**
3. Selecciona **"Select metric"** → **"Billing"** → **"Total Estimated Charge"**
4. Configura el umbral (ej: $5.00)
5. Configura notificación por email
6. Crea la alarma

Ahora recibirás un email si tus costos superan el umbral.

---

## 📊 Revisar tu Factura

### Ver Costos Actuales

1. Ve a [Billing Dashboard](https://console.aws.amazon.com/billing/)
2. Haz clic en **"Bills"**
3. Selecciona el mes actual
4. Revisa los cargos por servicio

### Usar Cost Explorer

1. Ve a **"Cost Explorer"** en el menú de Billing
2. Analiza tus gastos por servicio, región y tiempo
3. Identifica recursos que generan costos

### Descargar Reporte

1. En Billing Dashboard, ve a **"Bills"**
2. Haz clic en **"Download CSV"**
3. Analiza el reporte en Excel o Google Sheets

---

## ❓ Preguntas Frecuentes

### ¿Qué pasa si olvido eliminar recursos?

Seguirás acumulando cargos hasta que los elimines. Revisa tu factura regularmente y configura alarmas de facturación.

### ¿Puedo recuperar una instancia terminada?

No. Terminar una instancia es permanente. Sin embargo, si configuraste el volumen EBS para que no se elimine, puedes recuperar los datos del volumen.

### ¿Cuánto tiempo tengo para eliminar recursos sin cargos?

Depende del Free Tier:
- Primeros 12 meses: 750 horas/mes de t2.micro gratis
- Después de 12 meses: Empiezas a pagar inmediatamente

### ¿Qué pasa con mis datos de Vaultwarden?

Si eliminas el volumen EBS, perderás todos tus datos. Asegúrate de hacer un backup si quieres conservar tus contraseñas.

### ¿Cómo hago un backup de Vaultwarden?

```bash
# Conectarse por SSH
ssh -i ~/.ssh/vaultwarden-key.pem ec2-user@TU_IP

# Crear backup
sudo tar -czf vaultwarden-backup.tar.gz /vw-data/

# Copiar a tu computadora (desde tu máquina local)
scp -i ~/.ssh/vaultwarden-key.pem ec2-user@TU_IP:~/vaultwarden-backup.tar.gz ~/Downloads/
```

---

## 🆘 Ayuda Adicional

### Soporte de AWS

Si tienes problemas para eliminar recursos:

1. Ve a [AWS Support Center](https://console.aws.amazon.com/support/)
2. Crea un caso de soporte
3. Incluso el plan gratuito tiene soporte de facturación

### Documentación

- [Terminar Instancias EC2](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/terminating-instances.html)
- [Liberar Elastic IPs](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/elastic-ip-addresses-eip.html#using-instance-addressing-eips-releasing)
- [Eliminar Volúmenes EBS](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-deleting-volume.html)

---

## 💡 Consejos Finales

1. **Limpia inmediatamente**: No esperes. Elimina recursos tan pronto como termines de usarlos.

2. **Revisa semanalmente**: Durante tus primeros meses con AWS, revisa tu factura semanalmente.

3. **Usa tags**: Etiqueta todos tus recursos con tags como `Project: Workshop` para identificarlos fácilmente.

4. **Configura alarmas**: Siempre configura alarmas de facturación antes de crear recursos.

5. **Documenta**: Anota qué recursos creaste y cuándo, para no olvidar eliminarlos.

6. **Automatiza**: Usa CDK o Terraform para que la limpieza sea tan simple como `cdk destroy`.

---

## ✅ Confirmación Final

Después de seguir esta guía, deberías tener:

- ✅ 0 instancias EC2 corriendo
- ✅ 0 Elastic IPs asignadas
- ✅ 0 volúmenes EBS huérfanos
- ✅ Factura de AWS sin cargos inesperados
- ✅ Alarmas de facturación configuradas

---

**¿Completaste la limpieza?** 🎉

¡Excelente! Ahora puedes estar tranquilo sabiendo que no tendrás cargos inesperados.

**¿Quieres hacer el workshop de nuevo?** Simplemente vuelve a la [Fase 1](fase-1-manual/README.md) y empieza desde cero.

**¿Preguntas?** Abre un Issue en el repositorio.
