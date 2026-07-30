# Guía Paso a Paso: Laboratorio AWS desde la Consola (Clics)
**AWS User Group Playa Vicente — Clase 2**

Esta guía contiene los pasos exactos para desplegar la arquitectura de la **Clase 2 (Amazon EC2 + IAM Role + Amazon S3)** utilizando únicamente la consola web de AWS.

**Bucket configurado para este laboratorio:** `awsugplayavicente123456789`

---

## 📌 Paso 1: Crear el Bucket de Amazon S3

1. En el buscador superior de la consola de AWS, escribe **S3** y entra al servicio.
2. Haz clic en el botón naranja **Crear bucket** (*Create bucket*).
3. En **Nombre del bucket**, ingresa exactamente:
   ```
   awsugplayavicente123456789
   ```
4. Asegúrate de que la **Región de AWS** sea `us-east-1` (N. Virginia).
5. Deja las demás opciones por defecto.
6. Desplázate hasta el final y haz clic en **Crear bucket**.

---

## 📌 Paso 2: Crear el Rol de IAM para la Instancia EC2

1. En el buscador superior, escribe **IAM** y entra al servicio.
2. En el menú lateral izquierdo, haz clic en **Roles** y luego en **Crear rol** (*Create role*).
3. Selecciona **Servicio de AWS** (*AWS service*) como tipo de entidad de confianza.
4. En la sección de *Caso de uso*, selecciona **EC2** y haz clic en **Siguiente**.
5. En la lista de políticas, busca y selecciona la casilla de:
   * `AmazonS3FullAccess`
6. Haz clic en **Siguiente**.
7. En **Nombre del rol**, escribe:
   ```
   EC2-S3-Upload-Role-Lab
   ```
8. Haz clic en **Crear rol** al final de la página.

---

## 📌 Paso 3: Crear el Grupo de Seguridad (*Security Group*)

1. En el buscador superior, entra a **EC2**.
2. En el menú lateral izquierdo, ve a **Grupos de seguridad** (*Security Groups*).
3. Haz clic en **Crear grupo de seguridad**.
4. Completa la sección de *Detalles básicos*:
   * **Nombre:** `ec2-demo-sg-lab`
   * **Descripción:** `Permitir tráfico HTTP (80) y SSH (22)`
   * **VPC:** Deja seleccionada la VPC por defecto.
5. En la sección **Reglas de entrada** (*Inbound rules*), haz clic en **Agregar regla** para crear 2 reglas:
   * **Regla 1:** 
     * Tipo: `HTTP`
     * Puerto: `80`
     * Origen: `Anywhere-IPv4` (`0.0.0.0/0`)
   * **Regla 2:** 
     * Tipo: `SSH`
     * Puerto: `22`
     * Origen: `Anywhere-IPv4` (`0.0.0.0/0`)
6. En **Reglas de salida** (*Outbound rules*), **NO agregues HTTP ni SSH**. Deja únicamente la regla por defecto (`All traffic` / `0.0.0.0/0`).
7. Haz clic en **Crear grupo de seguridad**.

---

## 📌 Paso 4: Lanzar la Instancia EC2 con el User Data

1. En el menú lateral de EC2, haz clic en **Instancias** y luego en **Lanzar instancias** (*Launch instances*).
2. **Nombre:** `Servidor-Demo-Clase-2`
3. **Imagen del sistema (AMI):** Selecciona **Amazon Linux** (*Amazon Linux 2023 AMI*).
4. **Tipo de instancia:** `t2.micro` (o `t3.micro`).
5. **Par de claves (Key pair):** Elige *"Continuar sin un par de claves"*.
6. **Configuración de red** (*Network settings*):
   * Haz clic en **Editar**.
   * En *Asignar automáticamente IP pública*, selecciona **Habilitar**.
   * En *Grupo de seguridad*, marca **Seleccionar un grupo de seguridad existente** y elige `ec2-demo-sg-lab`.
7. **Detalles avanzados** (*Advanced details*):
   * En **Perfil de instancia IAM** (*IAM instance profile*), selecciona el rol creado en el Paso 2: `EC2-S3-Upload-Role-Lab`.
   * Desplázate al cuadro de texto **Datos de usuario** (*User data*) al final de la página y copia y pega exactamente el siguiente código:

```bash
#!/bin/bash
dnf update -y || apt-get update -y
dnf install -y python3-pip cronie || apt-get install -y python3-pip cronie
systemctl enable --now crond || true
pip3 install flask boto3

cat << 'APP_EOF' > /app.py
import os
from flask import Flask, request, redirect, render_template_string
import boto3

app = Flask(__name__)
BUCKET_NAME = os.environ.get('BUCKET_NAME', 'awsugplayavicente123456789')
s3 = boto3.client('s3')

HTML_TEMPLATE = '''
<!doctype html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>AWS User Group Playa Vicente | Muro de la Nube</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        :root {
            --bg-dark: #080c16;
            --surface: #10172a;
            --surface-glass: rgba(16, 23, 42, 0.85);
            --border-color: #1e293b;
            --accent-purple: #a855f7;
            --accent-light: rgba(168, 85, 247, 0.15);
            --text-main: #ffffff;
            --text-muted: #cbd5e1;
            --gradient-btn: linear-gradient(135deg, #7c3aed, #a855f7);
            --gradient-text: linear-gradient(135deg, #e9d5ff, #c084fc, #a855f7);
            --spectrum-bar: linear-gradient(90deg, #5b21b6, #7c3aed, #a855f7, #60a5fa);
        }
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'Plus Jakarta Sans', sans-serif; background-color: var(--bg-dark); color: var(--text-main); min-height: 100vh; padding: 20px 12px; }
        .spectrum-bar { height: 4px; width: 100%; background: var(--spectrum-bar); position: fixed; top: 0; left: 0; z-index: 1000; }
        .container { max-width: 900px; margin: 10px auto 0 auto; }
        .glass-card { background: var(--surface-glass); backdrop-filter: blur(16px); border: 1px solid var(--border-color); border-radius: 20px; box-shadow: 0 15px 35px rgba(0, 0, 0, 0.45); }
        .hero-header { padding: 28px 20px; text-align: center; margin-bottom: 20px; }
        .badge-purple { display: inline-block; background: var(--accent-light); color: var(--accent-purple); font-size: 0.78rem; font-weight: 700; padding: 5px 14px; border-radius: 50px; border: 1px solid rgba(168, 85, 247, 0.3); margin-bottom: 12px; text-transform: uppercase; }
        h1 { font-size: 1.8rem; font-weight: 800; background: var(--gradient-text); -webkit-background-clip: text; -webkit-text-fill-color: transparent; margin-bottom: 8px; }
        .community-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(130px, 1fr)); gap: 10px; margin-bottom: 20px; }
        .social-card { background: var(--surface); border: 1px solid var(--border-color); border-radius: 14px; padding: 12px; text-align: center; text-decoration: none; color: var(--text-main); font-weight: 600; font-size: 0.85rem; transition: 0.25s; }
        .social-card:hover { border-color: var(--accent-purple); color: var(--accent-purple); transform: translateY(-2px); }
        .upload-section { padding: 24px 18px; margin-bottom: 24px; text-align: center; border: 2px dashed rgba(168, 85, 247, 0.3); }
        .preview-container { display: none; margin: 12px auto 16px auto; max-width: 240px; border-radius: 12px; overflow: hidden; border: 2px solid var(--accent-purple); }
        .preview-img { width: 100%; height: 160px; object-fit: cover; }
        .file-label-btn { background: var(--accent-light); color: var(--accent-purple); border: 1px solid rgba(168, 85, 247, 0.4); padding: 11px 20px; border-radius: 10px; font-weight: 600; font-size: 0.88rem; cursor: pointer; display: inline-block; }
        .btn-upload-submit { background: var(--gradient-btn); color: #fff; border: none; padding: 14px 28px; border-radius: 12px; font-weight: 700; font-size: 0.95rem; cursor: pointer; width: 100%; max-width: 300px; margin-top: 14px; }
        .gallery-container { padding: 24px 18px; }
        .gallery-topbar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 18px; }
        .gallery-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(160px, 1fr)); gap: 14px; }
        .card-photo { background: var(--surface); border: 1px solid var(--border-color); border-radius: 14px; overflow: hidden; transition: 0.25s; }
        .card-photo:hover { transform: translateY(-3px); border-color: var(--accent-purple); }
        .img-wrapper { width: 100%; height: 150px; overflow: hidden; background: #080c16; cursor: pointer; }
        .gallery-thumbnail { width: 100%; height: 100%; object-fit: cover; }
        .card-footer { padding: 10px 12px; display: flex; justify-content: space-between; align-items: center; }
        .photo-filename { font-size: 0.75rem; color: var(--text-muted); font-weight: 600; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; max-width: 100px; }
        .view-btn { background: var(--accent-light); color: var(--accent-purple); border: 1px solid rgba(168, 85, 247, 0.3); border-radius: 6px; padding: 3px 8px; font-weight: 700; font-size: 0.72rem; cursor: pointer; }
        .modal { display: none; position: fixed; z-index: 2000; top: 0; left: 0; width: 100%; height: 100%; background: rgba(8, 12, 22, 0.92); backdrop-filter: blur(12px); justify-content: center; align-items: center; padding: 15px; cursor: pointer; }
        .modal-content { max-width: 95%; max-height: 85vh; border-radius: 14px; border: 2px solid var(--accent-purple); object-fit: contain; }
        .close-hint { position: absolute; top: 20px; color: var(--text-muted); font-size: 0.85rem; background: rgba(16, 23, 42, 0.8); padding: 5px 14px; border-radius: 20px; border: 1px solid var(--border-color); }
        @media (max-width: 600px) { h1 { font-size: 1.45rem; } .gallery-grid { grid-template-columns: repeat(auto-fill, minmax(135px, 1fr)); } .img-wrapper { height: 130px; } }
    </style>
</head>
<body>
<div class="spectrum-bar"></div>
<div class="container">
    <header class="glass-card hero-header">
        <span class="badge-purple">AWS User Group Playa Vicente</span>
        <h1>Muro de Fotos en Vivo — Clase 2</h1>
        <p style="color: #cbd5e1; font-size: 0.9rem;">Amazon EC2 + IAM Role + Amazon S3</p>
    </header>

    <div class="community-grid">
        <a href="https://www.meetup.com/aws-user-group-playa-vicente/" target="_blank" class="social-card">Meetup</a>
        <a href="https://chat.whatsapp.com/JBdSseny4XM65dGBHHDgwS" target="_blank" class="social-card">WhatsApp</a>
        <a href="https://t.me/AUGPlayaVicente" target="_blank" class="social-card">Telegram</a>
        <a href="https://www.youtube.com/channel/UCObJL_Id1HHsx1hg0aNISlw" target="_blank" class="social-card">YouTube</a>
    </div>

    <section class="glass-card upload-section">
        <h2 style="color: #fff; font-size: 1.15rem; margin-bottom: 6px;">Sube tu captura de la Clase 2</h2>
        <form method="post" enctype="multipart/form-data" action="/upload">
            <div class="preview-container" id="previewBox">
                <img id="imagePreview" class="preview-img" src="" alt="Vista previa">
            </div>
            <label for="file-upload" class="file-label-btn" id="fileBtnLabel">Seleccionar imagen...</label>
            <input id="file-upload" type="file" name="file" accept="image/*" required style="display:none;" onchange="previewFile(this)"><br>
            <button type="submit" class="btn-upload-submit">Publicar Foto en S3</button>
        </form>
    </section>

    <section class="glass-card gallery-container">
        <div class="gallery-topbar">
            <h3 style="color:#fff;">Muro de la Comunidad ({{ imagenes|length }} fotos)</h3>
            <button onclick="location.reload();" class="btn-refresh">Actualizar</button>
        </div>
        <div class="gallery-grid">
            {% for item in imagenes %}
                <div class="card-photo">
                    <div class="img-wrapper" onclick="openModal('{{ item.url }}')">
                        <img src="{{ item.url }}" class="gallery-thumbnail" alt="Foto">
                    </div>
                    <div class="card-footer">
                        <span class="photo-filename" title="{{ item.key }}">{{ item.key }}</span>
                        <button type="button" class="view-btn" onclick="openModal('{{ item.url }}')">Ampliar</button>
                    </div>
                </div>
            {% else %}
                <p style="color: #cbd5e1; grid-column: 1/-1; text-align: center; padding: 35px 10px;">No hay fotos en el muro. Sé el primero en publicar.</p>
            {% endfor %}
        </div>
    </section>
</div>

<div id="photoModal" class="modal" onclick="this.style.display='none'">
    <span class="close-hint">Haz clic en cualquier lugar para cerrar</span>
    <img class="modal-content" id="fullPhoto">
</div>

<script>
    function previewFile(input) {
        if (input.files && input.files[0]) {
            const reader = new FileReader();
            reader.onload = function(e) {
                document.getElementById('imagePreview').src = e.target.result;
                document.getElementById('previewBox').style.display = 'block';
            }
            reader.readAsDataURL(input.files[0]);
            document.getElementById('fileBtnLabel').textContent = input.files[0].name;
        }
    }
    function openModal(url) {
        document.getElementById('fullPhoto').src = url;
        document.getElementById('photoModal').style.display = 'flex';
    }
    setTimeout(function() { location.reload(); }, 180000);
</script>
</body>
</html>
'''

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
APP_EOF

export BUCKET_NAME="awsugplayavicente123456789"
(crontab -l 2>/dev/null; echo "@reboot export BUCKET_NAME=awsugplayavicente123456789 && python3 /app.py &") | crontab -
python3 /app.py &
```

8. Haz clic en el botón **Lanzar instancia** (*Launch instance*).

---

## 📌 Paso 5: Probar la Aplicación Web

1. Espera unos **1 a 2 minutos** mientras la instancia inicia e instala las dependencias.
2. Ve a **Instancias** en la consola de EC2, selecciona tu instancia `Servidor-Demo-Clase-2` y copia su **Dirección IPv4 pública**.
3. Abre una pestaña nueva en tu navegador y visita:
   ```
   http://<TU_IP_PUBLICA>
   ```
4. Prueba subir una imagen. La imagen se almacenará directamente en tu bucket `awsugplayavicente123456789` y se desplegará en el muro de fotos.
