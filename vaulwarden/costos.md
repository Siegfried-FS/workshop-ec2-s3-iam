# 💰 Costos de AWS para el Workshop

Esta guía te ayudará a entender los costos asociados con el despliegue de Vaultwarden en AWS EC2 y cómo minimizarlos o evitarlos completamente.

## 📊 Resumen de Costos

| Recurso | Costo Mensual Estimado | Costo por Hora | Free Tier |
|---------|------------------------|----------------|-----------|
| **EC2 t2.micro** | $8.50 - $10.00 | ~$0.0116 | ✅ 750 horas/mes (12 meses) |
| **Elastic IP** | $0.00* | $0.00* | ✅ Gratis si está asociada |
| **Elastic IP (no asociada)** | $3.60 | $0.005 | ❌ Se cobra si no está en uso |
| **Almacenamiento EBS (8 GB)** | $0.80 | - | ✅ 30 GB/mes (12 meses) |
| **Transferencia de datos (salida)** | Variable | $0.09/GB | ✅ 15 GB/mes gratis |

*\*Gratis mientras la Elastic IP esté asociada a una instancia EC2 en ejecución*

### 💡 Costo Total Estimado

**Con Free Tier (primeros 12 meses):**
- ✅ **$0.00/mes** si usas menos de 750 horas/mes y eliminas recursos cuando no los uses

**Sin Free Tier:**
- 💵 **~$9-11/mes** si dejas la instancia corriendo 24/7
- 💵 **~$0.35/día** si solo la usas durante el workshop (2-3 horas)

## 🎁 AWS Free Tier

### ¿Qué es el Free Tier?

AWS ofrece un nivel gratuito para nuevos clientes durante los primeros **12 meses** después de crear la cuenta.

### ¿Qué incluye para este workshop?

#### EC2 (Instancias)
- **750 horas/mes** de instancias t2.micro de Linux
- Suficiente para ejecutar **1 instancia 24/7** durante todo el mes
- O **múltiples instancias** siempre que no superes 750 horas totales

#### Almacenamiento EBS
- **30 GB** de almacenamiento de propósito general (SSD)
- Nuestro workshop usa solo **8 GB**, así que estás cubierto

#### Transferencia de Datos
- **15 GB** de transferencia de datos de salida por mes
- Más que suficiente para uso personal de Vaultwarden

### ⚠️ Importante sobre el Free Tier

1. **Solo para cuentas nuevas**: El Free Tier de 12 meses solo aplica a cuentas creadas recientemente
2. **Límites mensuales**: Los 750 horas se reinician cada mes
3. **Región específica**: Algunos recursos del Free Tier son específicos por región
4. **Después de 12 meses**: Los costos normales aplican automáticamente

👉 [Verificar elegibilidad del Free Tier](https://aws.amazon.com/free/)

## 💸 Desglose Detallado de Costos

### 1. Instancia EC2 (t2.micro)

**Especificaciones:**
- 1 vCPU
- 1 GB RAM
- Rendimiento de red bajo a moderado

**Costos (región us-east-1):**
- **Por hora**: $0.0116
- **Por día**: $0.28
- **Por mes (730 horas)**: $8.47

**Costo durante el workshop:**
- Workshop de 1 hora: **$0.01** (prácticamente gratis)
- Dejar corriendo 1 día: **$0.28**
- Dejar corriendo 1 semana: **$1.96**

### 2. Elastic IP

**¿Qué es?**
Una dirección IP pública estática que puedes asociar a tu instancia.

**Costos:**
- **Asociada a instancia en ejecución**: $0.00 (gratis)
- **No asociada o instancia detenida**: $0.005/hora = $3.60/mes

⚠️ **Importante**: Si detienes tu instancia pero no liberas la Elastic IP, se te cobrará.

### 3. Almacenamiento EBS

**¿Qué es?**
El disco duro virtual de tu instancia EC2.

**Nuestro uso:**
- 8 GB de almacenamiento SSD (gp3)

**Costos:**
- **Por GB/mes**: $0.10
- **8 GB**: $0.80/mes

**Free Tier**: 30 GB/mes gratis (cubierto completamente)

### 4. Transferencia de Datos

**Entrada (hacia AWS):**
- ✅ **Gratis** (sin límite)

**Salida (desde AWS):**
- Primeros 15 GB/mes: **Gratis** (Free Tier)
- Después de 15 GB: $0.09/GB

**Uso estimado de Vaultwarden:**
- Uso personal ligero: **< 1 GB/mes**
- Uso moderado: **2-5 GB/mes**

## 🛡️ Cómo Minimizar Costos

### Durante el Workshop

1. **Usa el Free Tier**
   - Asegúrate de que tu cuenta sea elegible
   - Usa instancias t2.micro (cubiertas por Free Tier)

2. **Elimina recursos inmediatamente después**
   - Sigue la guía de [limpieza.md](limpieza.md)
   - No dejes recursos corriendo sin usar

3. **Libera la Elastic IP**
   - Si no la necesitas, libérala inmediatamente
   - Evita el cargo de $3.60/mes

### Para Uso Continuo

1. **Detén la instancia cuando no la uses**
   ```bash
   # Solo pagas por almacenamiento EBS (~$0.80/mes)
   # No pagas por la instancia detenida
   ```

2. **Configura alarmas de facturación**
   - Recibe alertas si superas un umbral
   - Evita sorpresas en tu factura

3. **Revisa tu factura mensualmente**
   - Identifica recursos no utilizados
   - Elimina lo que no necesites

## 📈 Calculadora de Costos

### Escenario 1: Solo Workshop (1-2 horas)
```
EC2 t2.micro (2 horas):        $0.02
Elastic IP (2 horas):          $0.00
Almacenamiento (1 día):        $0.03
Transferencia de datos:        $0.00
─────────────────────────────────────
TOTAL:                         ~$0.05
```

### Escenario 2: Uso Semanal (24/7 por 1 semana)
```
EC2 t2.micro (168 horas):      $1.95
Elastic IP:                    $0.00
Almacenamiento (7 días):       $0.18
Transferencia de datos:        $0.00
─────────────────────────────────────
TOTAL:                         ~$2.13
```

### Escenario 3: Uso Mensual (24/7)
```
EC2 t2.micro (730 horas):      $8.47
Elastic IP:                    $0.00
Almacenamiento (30 días):      $0.80
Transferencia de datos:        $0.00
─────────────────────────────────────
TOTAL:                         ~$9.27
```

**Con Free Tier**: $0.00 (todo cubierto)

## 🔔 Configurar Alarmas de Facturación

### Paso 1: Habilitar Alertas de Facturación

1. Ve a la consola de AWS
2. Haz clic en tu nombre de usuario (arriba a la derecha)
3. Selecciona "Billing and Cost Management"
4. En el menú izquierdo, selecciona "Billing preferences"
5. Marca "Receive Billing Alerts"
6. Guarda las preferencias

### Paso 2: Crear una Alarma en CloudWatch

1. Ve a CloudWatch en la consola de AWS
2. Selecciona "Alarms" → "Create alarm"
3. Selecciona "Select metric" → "Billing" → "Total Estimated Charge"
4. Configura el umbral (ej: $5.00)
5. Configura notificación por email
6. Crea la alarma

## 🧮 Herramientas Útiles

### AWS Pricing Calculator
Calcula costos estimados para tu configuración específica:
👉 [https://calculator.aws/](https://calculator.aws/)

### AWS Cost Explorer
Analiza tus gastos actuales y proyectados:
👉 Disponible en la consola de AWS → Billing

### AWS Budgets
Configura presupuestos y recibe alertas:
👉 Disponible en la consola de AWS → Billing → Budgets

## ⚠️ Advertencias Importantes

### 1. Recursos Olvidados
Los costos más comunes vienen de recursos que se olvidan:
- ❌ Instancias EC2 corriendo sin uso
- ❌ Elastic IPs no asociadas
- ❌ Volúmenes EBS huérfanos
- ❌ Snapshots antiguos

### 2. Después del Free Tier
Después de 12 meses, los costos normales aplican automáticamente:
- No hay notificación previa
- Los recursos siguen corriendo
- Empiezas a pagar las tarifas estándar

### 3. Múltiples Instancias
Si creas múltiples instancias durante el workshop:
- Las horas se suman
- Puedes superar las 750 horas del Free Tier
- Elimina instancias de prueba inmediatamente

## 🧹 Limpieza = Ahorro

**La mejor forma de evitar costos es eliminar recursos cuando no los uses.**

Sigue la guía completa de limpieza: [limpieza.md](limpieza.md)

### Checklist de Limpieza Rápida

```
✅ Terminar instancia EC2
✅ Liberar Elastic IP
✅ Eliminar volúmenes EBS huérfanos
✅ Eliminar Security Groups personalizados
✅ Verificar en la consola que no queden recursos
```

## 📞 Soporte de Facturación de AWS

Si tienes preguntas sobre tu factura:

1. **AWS Support Center**
   - Disponible en la consola de AWS
   - Incluso el plan gratuito tiene soporte de facturación

2. **Documentación de Facturación**
   👉 [https://docs.aws.amazon.com/awsaccountbilling/](https://docs.aws.amazon.com/awsaccountbilling/)

## 💡 Consejos Finales

1. **Revisa tu factura regularmente** (al menos una vez por semana durante el aprendizaje)
2. **Configura alarmas de facturación** antes de crear recursos
3. **Elimina recursos inmediatamente** después del workshop
4. **Usa el Free Tier sabiamente** durante tus primeros 12 meses
5. **Documenta tus recursos** para no olvidar eliminarlos

---

**Recuerda**: Este workshop está diseñado para ser económico o gratuito si usas el Free Tier y eliminas los recursos al terminar.

👉 **Siguiente paso**: Revisa [limpieza.md](limpieza.md) para saber cómo eliminar recursos
