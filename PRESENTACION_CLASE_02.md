# Guión Pedagógico de Carpintería y Presentación — Clase 2

**Programa:** De Cero a Cloud  
**Organiza:** AWS User Group Playa Vicente  
**Instructor:** Roberto Flores  
**Tema:** Amazon EC2 + Modelos Nube (IaaS/PaaS/SaaS) + AWS IAM Roles  

---

## Diapositiva 1: Bienvenida e Introducción
* **Texto en Pantalla:**
  * Clase 2: Tu Carpintería a la Medida en la Nube (Amazon EC2) y Permisos con Gafetes de Turno (AWS IAM Roles)
  * Programa De Cero a Cloud — AWS User Group Playa Vicente
  * Instructor: Roberto Flores
* **Guión Pedagógico (Lo que dices al aire):**
  "Bienvenidos a la segunda clase de De Cero a Cloud. Mi nombre es Roberto Flores. Hoy explicaremos cómo funciona la nube con una analogía muy real y práctica: un taller de carpintería. Pasaremos de tener una simple bodega de almacenamiento a equipar nuestra propia carpintería en la nube para poner a trabajar nuestras herramientas."

---

## Diapositiva 2: Agenda de la Sesión
* **Texto en Pantalla:**
  1. Repaso de la Clase 1 (Amazon S3)
  2. ¿Qué es IaaS, PaaS y SaaS? (La metodología del taller de carpintería)
  3. Amazon EC2: Tu carpintería a la medida en AWS
  4. Componentes clave: AMI, Instancia, Security Groups y Puertos
  5. Seguridad con IAM Roles (Gafetes de turno)
  6. Laboratorio en Vivo: Muro de la comunidad
  7. Experimento de seguridad en vivo
  8. Retos de la semana y preguntas

---

## Diapositiva 3: Repaso de la Clase 1 — Almacenamiento (S3)
* **Texto en Pantalla:**
  * Clase 1: Amazon S3 como la bodega de muebles o productos terminados.
  * Almacenamiento estático sin herramientas de corte.
* **Guión Pedagógico:**
  "En la Clase 1 vimos que S3 es como una gran bodega donde guardas tus productos o muebles terminados. Pero la bodega por sí sola no trabaja la madera ni arma estructuras. Hoy necesitamos encender una carpintería activa equipada con herramientas."

---

## Diapositiva 4: Modelos de Servicio Nube (La Metodología de la Carpintería)
* **Texto en Pantalla:**
  * On-Premises: El local completo propio (pagar luz, comprar maquinaria, pagar renta).
  * IaaS (Infraestructura): AWS te da la carpintería a la medida; tú como carpintero experto construyes libremente. *Ejemplo: Amazon EC2*.
  * PaaS (Plataforma): El taller con herramientas listas; tú solo pones la mano de obra para armar la pieza final. *Ejemplo: AWS App Runner*.
  * SaaS (Software): La mueblería; el cliente compra el mueble terminado listo para usar. *Ejemplo: Gmail, Netflix, Vaultwarden*.
* **Guión Pedagógico:**
  "Pensemos en cómo funciona la nube: On-Premises es cuando tú tienes el local completo de la carpintería: pagas la renta, la luz industrial, compras las máquinas y das mantenimiento. IaaS (Amazon EC2) es cuando tú eres el carpintero con experiencia, pero AWS te da la carpintería a la medida que necesitas; tú no compras el local ni las máquinas, AWS te da el espacio y la energía y tú te encargas de la carpintería. PaaS es cuando AWS te tiene todo el taller y las herramientas listas y tú solo pones la mano de obra para ensamblar. Y SaaS es la mueblería: el cliente llega, escoge el mueble listo y se lo lleva a su casa."

---

## Diapositiva 5: ¿Qué es Amazon EC2 y cómo usar la Capa Gratuita?
* **Texto en Pantalla:**
  * Amazon EC2 = Tu carpintería a la medida en la nube.
  * Enciende, apaga o cambia la potencia del taller en segundos.
  * Capa Gratuita: Instancias `t2.micro` (o `t3.micro`) con 750 horas al mes durante 12 meses.
* **Guión Pedagógico:**
  "Amazon EC2 es tu carpintería a la medida en AWS. Si hoy necesitas una sierra pequeña usas t2.micro, que es totalmente gratuita. Si mañana necesitas una cortadora industrial, cambias de tamaño con un clic y pagas solo por los minutos que la usaste."

---

## Diapositiva 6: Transición Clave — La Bodega (S3) vs. La Carpintería (EC2)
* **Texto en Pantalla:**
  * S3 (Bodega): Guarda y entrega productos o muebles terminados sin modificar nada.
  * EC2 (Carpintería): Corta, ensambla y procesa información con programas en Python.
* **Guión Pedagógico:**
  "A veces surge la duda: '¿Por qué nos sirve EC2 si S3 ya guardaba archivos?' La razón es que la bodega S3 no arma muebles. Necesitamos la carpintería de EC2 para ejecutar nuestro código en Python que recibe las fotos de los alumnos, las procesa y las acomoda en el almacén."

---

## Diapositiva 7: Componentes Clave de una Instancia EC2
* **Texto en Pantalla:**
  * AMI: El plano base del taller (Amazon Linux 2023).
  * Tipo de Instancia: Potencia del banco de trabajo (`t2.micro` = 1 vCPU / 1 GB RAM).
  * Security Group: El portón de entrada y reglas de acceso al taller.
  * Puertos de Red:
    * Puerto 80 (HTTP): Mostrador público para clientes de la web.
    * Puerto 22 (SSH): Puerta trasera privada de mantenimiento para el carpintero.
  * User Data: Instructivo de arranque e inicio automático.
* **Guión Pedagógico (Explicación para principiantes):**
  "Para armar nuestra carpintería en EC2 necesitamos entender 5 piezas sencillas:  
  1. La **AMI** es el plano arquitectónico que define qué sistema operativo tendrá la máquina.  
  2. El **Tipo de Instancia (t2.micro)** es la capacidad de nuestro banco de trabajo: cuánta potencia de motor (vCPU) y memoria (RAM) le ponemos.  
  3. El **Security Group** es el portón de seguridad. En AWS todas las puertas vienen cerradas por defecto.  
  4. Los **Puertos de Red** son los accesos con número: abrimos el **Puerto 80** que es el mostrador público por donde los clientes entran a ver la web desde su celular, y el **Puerto 22** que es la puerta privada con llave para que tú como administrador entres a dar mantenimiento por consola.  
  5. El **User Data** es la lista de preparación automatizada que enciende luces y herramientas solo la primera vez que se presiona el interruptor principal."

---

## Diapositiva 8: AWS IAM — Gafetes de Turno vs. Llaves Maestras
* **Texto en Pantalla:**
  * Regla de Oro: NUNCA dejes las llaves de la carpintería colgadas ni contraseñas escritas en el código.
  * Usuarios IAM: Llaves individuales para carpinteros.
  * IAM Roles: Gafetes de turno temporales para herramientas y máquinas.
* **Guión Pedagógico:**
  "En un taller seguro no dejas las llaves maestras pegadas en la pared. Le das a cada ayudante un gafete de turno que vence al salir. Eso hace el IAM Role: le entrega a nuestra EC2 un gafete digital para mover materiales a la bodega S3 sin necesidad de escribir contraseñas fijas en el programa."

---

## Diapositiva 9: Arquitectura del Laboratorio de Hoy
* **Texto en Pantalla:**
  * Alumno -> EC2 Carpintería (Flask en Puerto 80) -> IAM Role (Gafete) -> Bucket S3 (Bodega).
  * Presigned URLs: Vouchers temporales para mostrar fotos de forma segura.

---

## Diapositiva 10: Demostración en Vivo
* **Texto en Pantalla:**
  * Despliegue automatizado con `deploy.sh`.
  * Dirección de acceso: `http://<IP_PUBLICA>`
  * Dinámica: Subir foto o captura de pantalla de la clase en vivo.

---

## Diapositiva 11: Experimento de Seguridad en Vivo
* **Texto en Pantalla:**
  * Experimento: Quitar el gafete (IAM Role) a la EC2 en vivo desde la consola de AWS.
  * Prueba: Intentar publicar una imagen.
  * Resultado: Error de credenciales.
* **Guión Pedagógico:**
  "Le quitaremos el gafete a la máquina en tiempo real. Al intentar subir una foto, verán que el sistema falla. Esto demuestra que la máquina no tenía llaves maestras escondidas."

---

## Diapositiva 12: Retos de la Semana 2 y Comunidad
* **Texto en Pantalla:**
  * Track 1 (Nuevos): Practicar en AWS Skill Builder / Educate ($0, sin tarjeta).
  * Track 2 (Avanzados): Replicar el laboratorio en consola real o explorar Vaultwarden.
  * Canales: Meetup, WhatsApp, Telegram, YouTube (Q&A).
