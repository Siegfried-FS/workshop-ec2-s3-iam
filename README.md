# Semana 2 — EC2 + SaaS/IaaS/PaaS + IAM Roles + S3

**Fecha:** Miércoles 29 de julio de 2026, 7:00 PM (hora CDMX)  
**Evento en Meetup:** [AWS User Group Playa Vicente](https://www.meetup.com/aws-user-group-playa-vicente/events/315867136/)  
**Organizado por:** AWS User Group Playa Vicente  
**Instructor:** Roberto Flores  

---

## Prerrequisito: Cómo Configurar tu Identidad de AWS CLI

Antes de ejecutar el script de despliegue automatizado, cualquier estudiante o usuario debe tener configurada su identidad de AWS en su terminal local.

### 1. Ejecutar la configuración de AWS CLI
Abre tu terminal y escribe:
```bash
aws configure
```

### 2. Explicación para Principiantes de los 4 Datos Solicitados

* **AWS Access Key ID:**  
  Es tu **nombre de usuario de terminal**. Es una clave pública que identifica a tu cuenta o usuario de IAM cuando te conectas desde la línea de comandos (funciona como tu número de credencial).

* **AWS Secret Access Key:**  
  Es tu **contraseña secreta de terminal**. Se utiliza para firmar digitalmente cada comando que envías a AWS. **Regla de seguridad:** Nunca compartas tu Secret Key ni la subas a GitHub.

* **Default region name (`us-east-1`):**  
  Es la **ubicación geográfica del centro de datos de AWS** donde deseas que se creen tus servidores de forma predeterminada (usamos `us-east-1`, N. Virginia).

* **Default output format (`json`):**  
  Es el **formato de respuesta** en el que AWS te devolverá la información cuando ejecutes comandos (JSON es el estándar universal legible por programas).

---

### 3. Verificar que tu identidad está activa (`aws sts get-caller-identity`)

Para confirmar que tus claves funcionan, ejecuta:
```bash
aws sts get-caller-identity
```

* **¿Qué hace este comando?:**  
  Es la pregunta **"¿Quién soy yo en AWS?"**. Consulta a los servidores de seguridad de AWS (STS - Security Token Service) para que revisen tus llaves y te confirmen a qué cuenta perteneces (`Account`) y con qué usuario estás conectado (`Arn`).

Si el comando te devuelve tu Account ID y tu ARN, tu terminal está 100% lista para ejecutar el laboratorio.

---

## Despliegue Automatizado para el Instructor y Estudiantes

Una vez configurada tu identidad con `aws configure`, navega a la carpeta `semana-02/lab` y ejecuta:

```bash
# 1. Desplegar todo automáticamente en tu cuenta de AWS
bash deploy.sh

# 2. Al finalizar la clase o tus pruebas, eliminar todos los recursos
bash cleanup.sh
```

> **Personalización Opcional:** Si deseas cambiar los prefijos o nombres por defecto de tus recursos (Bucket S3, IAM Role, Security Group), puedes modificar las líneas 31-34 en `lab/deploy.sh`:
> ```bash
> BUCKET_NAME="tu-prefijo-bucket-${UNIQUE_ID}"
> ROLE_NAME="Tu-Nombre-De-Rol-${UNIQUE_ID}"
> SG_NAME="tu-grupo-de-seguridad-${UNIQUE_ID}"
> ```

---

## Objetivos de la Clase

1. **Modelos de Servicio Nube:** Diferencias entre **IaaS, PaaS y SaaS** (Metodología del Taller de Carpintería).
2. **Amazon EC2 y sus Componentes Base:** AMI, Tipo de Instancia, Security Groups, Puertos (80 y 22) y User Data.
3. **AWS IAM Roles:** Seguridad de identidades sin guardar llaves estáticas (`AWS_ACCESS_KEY`).
4. **Laboratorio Interactivo en Vivo:** Desplegar una aplicación web adaptativa para móviles donde los alumnos podrán **subir capturas de pantalla de la clase en vivo al S3 de la comunidad** mientras promocionamos los canales del **AWS User Group Playa Vicente**.

---

## PARTE 1: TEORÍA Y CONCEPTOS

### 1. Modelos de Servicio Nube (La Metodología de la Carpintería)

Para entender cómo funciona la nube, utilizamos la perspectiva de un taller de carpintería:

| Modelo | Descripción | ¿Quién administra la infraestructura? | Metodología de Carpintería | Ejemplo Real en AWS |
|---|---|---|---|---|
| **On-Premises** | Infraestructura local tradicional | Tú compras y mantienes todo | **Tener el local completo propio:** Tú pagas la renta del local, la luz industrial, compras la maquinaria, das mantenimiento y compras la madera. | Tu laptop o servidor físico en oficina |
| **IaaS** *(Infraestructura como Servicio)* | Alquilas servidores y red a la medida en la nube | AWS te da el taller y la infraestructura; **tú como carpintero trabajas y construyes libremente** | **AWS te da la carpintería a la medida:** Tú eres el carpintero experimentado. No compras el local ni las máquinas; AWS te da el espacio y la energía a la medida que necesitas y tú te encargas de la carpintería. | **Amazon EC2**, Amazon VPC |
| **PaaS** *(Plataforma como Servicio)* | Entorno preparado para ejecutar código | AWS administra todo el taller y herramientas; **tú solo pones la mano de obra** | **El taller equipado con herramientas listas:** AWS te tiene todo el taller montado y ajustado. Tú solo pones la mano de obra para armar la pieza final sin preocuparte por mantener las máquinas. | AWS App Runner, Elastic Beanstalk |
| **SaaS** *(Software como Servicio)* | Aplicación web lista para usar | El proveedor administra **todo el producto y la mueblería** | **La mueblería:** Es la tienda. El cliente entra, selecciona el mueble terminado y se lo lleva a casa listo para usar. | Gmail, Netflix, Microsoft 365 |

---

### 2. Desglose Detallado de Amazon EC2 para Principiantes

Para quien entra por primera vez al mundo cloud, Amazon EC2 no es una "caja negra". Se compone de 5 elementos básicos explicados a detalle:

#### A. AMI (Amazon Machine Image)
* **¿Qué es en la nube?:** Es la plantilla preconfigurada con el Sistema Operativo que tendrá tu servidor (ej. Amazon Linux 2023, Ubuntu, Windows Server).
* **Analogía de Carpintería:** Es el **plano arquitectónico del taller**. Antes de empezar a trabajar, el plano define qué tipo de suelo, estructura y sistema base tendrá el área de trabajo.

#### B. Tipo de Instancia (Instance Type — ej. `t2.micro`)
* **¿Qué es en la nube?:** Define la potencia de cómputo del servidor: la cantidad de núcleos de procesador (vCPU) y memoria RAM.
  * **Capa Gratuita:** La instancia **`t2.micro`** (1 vCPU y 1 GB de RAM) incluye 750 horas mensuales sin costo durante 12 meses. Si tu región de AWS no ofrece la serie t2, AWS asigna **`t3.micro`** de forma equivalente.
* **Analogía de Carpintería:** Es la **potencia del banco de trabajo**. Define qué tan grande es la mesa y cuántos caballos de fuerza tiene la sierra principal para cortar rápido o lento.

#### C. Security Group (Grupo de Seguridad)
* **¿Qué es en la nube?:** Es un **firewall virtual a nivel de red**. Por defecto, en AWS todas las conexiones entrantes están bloqueadas. El Security Group contiene las reglas que dicen quién tiene permitido entrar al servidor.
* **Analogía de Carpintería:** Es la **cerca y portón de seguridad de la carpintería**. Decide qué puertas o ventanillas se abren al exterior.

#### D. Puertos de Red (Ports — ej. Puerto 80 HTTP y Puerto 22 SSH)
* **¿Qué son en la nube?:** Un puerto es un número virtual en la tarjeta de red que conecta a un programa específico dentro del servidor.
  * **Puerto 80 (HTTP):** Es la puerta web estándar. Se abre al público (`0.0.0.0/0`) para que cualquier persona en internet pueda ver tu página web.
  * **Puerto 22 (SSH):** Es la puerta de administración por consola remota. Permite conectarse de forma segura a la terminal del servidor para darle mantenimiento.
* **Analogía de Carpintería:**
  * **Puerto 80:** El mostrador de exhibición al frente del negocio por donde entran los clientes.
  * **Puerto 22:** La puerta trasera privada con cerradura donde entra exclusivamente el carpintero para reparar las herramientas.

#### E. User Data (Datos del Usuario)
* **¿Qué es en la nube?:** Es un script automatizado en Bash que el servidor ejecuta con privilegios de administrador **únicamente la primera vez que se enciende**.
* **Analogía de Carpintería:** La **lista de preparación del taller**. El procedimiento que se ejecuta automáticamente al subir el interruptor general por primera vez (encender extractores, encender luces y preparar las herramientas de trabajo).

---

### 3. AWS IAM: Usuarios vs. Roles (Seguridad)

> **REGLA DE ORO DE SEGURIDAD:**  
> NUNCA dejes las llaves maestras de la carpintería colgadas en la pared ni guardes `AWS_ACCESS_KEY_ID` o `AWS_SECRET_ACCESS_KEY` dentro del código de tu servidor.

* **Usuarios IAM:** Como las llaves personales entregadas a un carpintero específico (tienen credenciales de largo plazo).
* **IAM Roles:** Como un gafete de turno temporal. La máquina EC2 recibe un gafete digital que le permite mover material a la bodega S3 de forma segura y cuyas credenciales rotan automáticamente.

---

## PARTE 2: LABORATORIO INTERACTIVO (Muro Colectivo en EC2 + S3)

En esta demo desplegaremos una aplicación web móvil adaptativa con los botones oficiales de nuestra comunidad (**Meetup, WhatsApp, Telegram, YouTube**) donde los alumnos podrán entrar desde sus celulares con la IP de tu EC2 y subir fotos de la clase al instante.

```
[ Alumno (Celular / Laptop) ] ──(Puerto 80 HTTP)──> [ EC2 Carpintería (Flask) ] ──(IAM Role Gafete)──> [ Bucket S3 Bodega ]
```

---

## PARTE 3: PREGUNTAS FRECUENTES (FAQ)

### ¿Por qué usamos EC2 si en la Clase 1 usamos S3 para la web?
* **Amazon S3 (Clase 1):** Es como la bodega de almacenamiento de productos o muebles terminados. Solo guarda y entrega archivos estáticos.
* **Amazon EC2 (Clase 2):** Es la carpintería activa donde las herramientas (código en Python/Flask) procesan el material en vivo.

### ¿Cuál tipo de instancia debo elegir para no tener costo en AWS?
Debes seleccionar **`t2.micro`** (o **`t3.micro`** si tu región de AWS no ofrece `t2`). Ambas ofrecen 750 horas mensuales dentro de la Capa Gratuita durante 12 meses.

### ¿Por qué no debemos guardar las imágenes dentro del disco duro de la EC2?
Porque las instancias EC2 son efímeras. Si apagas o eliminas la carpintería virtual y tenías material guardado ahí dentro, se perderá. Los productos terminados siempre deben enviarse a la bodega central de S3.

---

## PARTE 4: EXPLICACIÓN DEL CÓDIGO PASO A PASO

> **Nota:** No necesitas modificar ningún archivo ni editar líneas de código manualmente. Al ejecutar `bash deploy.sh`, el sistema genera automáticamente un nombre de bucket S3 único a nivel global (con formato `galeria-aws-playa-vicente-<timestamp>-<hash>`) e inyecta la variable de entorno en el servidor EC2.

```bash
#!/bin/bash
dnf update -y || apt-get update -y
dnf install -y python3-pip cronie || apt-get install -y python3-pip cronie
systemctl enable --now crond || true
pip3 install flask boto3

# BUCKET_NAME inyectado automáticamente por deploy.sh
export BUCKET_NAME="galeria-aws-playa-vicente-1722345678-abc12"

cat << 'EOF' > /app.py
... (Código de la aplicación web) ...
EOF

(crontab -l 2>/dev/null; echo "@reboot export BUCKET_NAME=$BUCKET_NAME && python3 /app.py &") | crontab -
python3 /app.py &
```

---

### B. La Aplicación Web en Python (`lab/app.py`)

```python
import os
from flask import Flask, request, redirect, render_template_string
import boto3

app = Flask(__name__)
BUCKET_NAME = os.environ.get('BUCKET_NAME', 'galeria-aws-playa-vicente')
s3 = boto3.client('s3')

@app.route('/', methods=['GET'])
def index():
    imagenes = []
    try:
        res = s3.list_objects_v2(Bucket=BUCKET_NAME)
        for obj in res.get('Contents', []):
            key = obj['Key']
            url = s3.generate_presigned_url(
                'get_object',
                Params={'Bucket': BUCKET_NAME, 'Key': key},
                ExpiresIn=3600
            )
            imagenes.append({'key': key, 'url': url})
    except Exception:
        imagenes = []
    return render_template_string(HTML_TEMPLATE, bucket=BUCKET_NAME, imagenes=imagenes)

@app.route('/upload', methods=['POST'])
def upload():
    file = request.files.get('file')
    if file and file.filename:
        try:
            s3.upload_fileobj(file, BUCKET_NAME, file.filename)
        except Exception:
            pass
    return redirect('/')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)
```

---

## Comunidad y Canales Oficiales

* **Meetup:** [AWS User Group Playa Vicente](https://www.meetup.com/aws-user-group-playa-vicente/)
* **WhatsApp:** [Grupo Oficial de Soporte](https://chat.whatsapp.com/JBdSseny4XM65dGBHHDgwS)
* **Telegram:** [Canal de Noticias](https://t.me/AUGPlayaVicente)
* **YouTube:** [Canal de Grabaciones](https://www.youtube.com/channel/UCObJL_Id1HHsx1hg0aNISlw)
