# Guía Rápida y Acordeón del Instructor — Clase 2 en Vivo

**Uso:** Ten este archivo abierto en una segunda pantalla, teléfono o tablet durante la transmisión.

---

## ⏱️ Minuto 00 - 05 | Bienvenida e Interacción
* **Qué decir:** Bienvenida a "De Cero a Cloud". Explicar que hoy aprenderemos a encender una computadora en AWS sin guardar contraseñas.
* **Pregunta al chat:** "Escriban un 1 en el chat si es la primera vez que crean un servidor en la nube."

---

## ⏱️ Minuto 05 - 15 | Teoría con la Analogía de la Carpintería
* **On-Premises:** Es tener el local completo propio (pagar luz, renta, comprar máquinas y madera).
* **IaaS (Amazon EC2):** AWS te da la carpintería a la medida con el espacio y la luz que necesitas; tú como carpintero experto trabajas libremente.
* **PaaS (AWS App Runner):** El taller con herramientas preajustadas; tú solo pones la mano de obra para dar el barniz final.
* **SaaS (Gmail / Netflix):** La mueblería; el cliente compra la mesa lista para usar.
* **Pregunta al chat:** "¿Qué creen que sea Google Drive: IaaS, PaaS o SaaS?"

---

## ⏱️ Minuto 15 - 25 | Conceptos Clave de EC2 e IAM
* **Amazon EC2:** Tu banco de trabajo en la nube.
* **`t2.micro`:** Banco compacto de 1 vCPU (potencia del motor) y 1 GB RAM (espacio de la mesa). Gratis en la Capa Gratuita (750h/mes).
* **Security Group:** El portón de entrada.
  * **Puerto 80:** Mostrador público para clientes web.
  * **Puerto 22:** Puerta trasera privada para mantenimiento.
* **IAM Role:** Gafete de turno temporal. Otorga permisos a la EC2 sin guardar contraseñas ni llaves en el código.

---

## ⏱️ Minuto 25 - 45 | Demostración en Vivo
1. En tu terminal ejecuta:
   ```bash
   cd semana-02/lab
   bash deploy.sh
   ```
2. Muestra en pantalla la IP pública que arroja el script (`http://<IP_PUBLICA>`).
3. **Instrucción a los alumnos:** "Entren desde su celular a esta IP y suban una captura de pantalla del en vivo".
4. Muestra cómo van apareciendo las fotos en el muro colectivo.

---

## ⏱️ Minuto 45 - 50 | Experimento de Seguridad en Vivo (Cómo quitar el IAM Role)

### Opción A: Desde la Consola Web de AWS
1. Entra a la consola de **EC2** -> Menú lateral izquierdo: **Instancias**.
2. Selecciona la casilla de tu servidor `Servidor-Demo-Clase-2`.
3. Haz clic en el botón superior **Acciones** -> **Seguridad** -> **Modificar rol IAM**.
4. En el menú desplegable selecciona **Sin rol IAM** (o haz clic en **Desasociar rol IAM**) y guarda los cambios.

### Opción B: En 1 segundo desde tu terminal
```bash
aws ec2 disassociate-iam-instance-profile --association-id $(aws ec2 describe-iam-instance-profile-associations --query "IamInstanceProfileAssociations[0].AssociationId" --output text)
```

### Prueba y Explicación
* Intenta subir una foto desde la página web en vivo. Fallará inmediatamente.
* **Qué decir:** "Al quitarle el gafete a la máquina, la app falla. Esto demuestra que la aplicación no tenía contraseñas guardadas en duro, sino que dependía 100% del rol de AWS".

---

## ⏱️ Minuto 50 - 60 | Limpieza y Cierre
1. En tu terminal ejecuta:
   ```bash
   bash cleanup.sh
   ```
2. Muestra que todos los recursos se eliminaron a $0 costo.
3. Explicar los Retos de la Semana 2 (Track Nuevos en Skill Builder vs Track Avanzados en consola).
4. Recordar los grupos de WhatsApp, Telegram y Meetup.
