#!/bin/bash
# ==============================================================================
# Script de Despliegue Automatizado — Clase 2: De Cero a Cloud
# AWS User Group Playa Vicente
# ==============================================================================

set -e

REGION="${AWS_REGION:-us-east-1}"

echo "[INFO] Validando credenciales de AWS y cuenta activa..."
CALLER_INFO=$(aws sts get-caller-identity --output json 2>/dev/null || true)

if [ -z "$CALLER_INFO" ]; then
    echo "[ERROR] No se pudieron obtener las credenciales de AWS."
    echo "[INFO] Asegurate de haber ejecutado 'aws configure' o configurado las variables de entorno."
    exit 1
fi

ACCOUNT_ID=$(echo "$CALLER_INFO" | grep -o '"Account": "[^"]*' | cut -d'"' -f4)
ARN=$(echo "$CALLER_INFO" | grep -o '"Arn": "[^"]*' | cut -d'"' -f4)

echo "   [OK] Conectado exitosamente a AWS."
echo "   Account ID: ${ACCOUNT_ID}"
echo "   ARN: ${ARN}"
echo ""

# Generar sufijo unico con timestamp y caracteres aleatorios
RANDOM_HASH=$(head /dev/urandom | tr -dc 'a-z0-9' | head -c 5)
UNIQUE_ID="$(date +%s)-${RANDOM_HASH}"
BUCKET_NAME="galeria-aws-playa-vicente-${UNIQUE_ID}"
ROLE_NAME="EC2-S3-Upload-Role-${UNIQUE_ID}"
PROFILE_NAME="EC2-S3-Upload-Profile-${UNIQUE_ID}"
SG_NAME="ec2-demo-sg-${UNIQUE_ID}"

# Inicializar archivo de recursos inmediatamente para que cleanup.sh siempre funcione
cat << EOF > .env.recursos_clase2
REGION=$REGION
BUCKET_NAME=$BUCKET_NAME
ROLE_NAME=$ROLE_NAME
PROFILE_NAME=$PROFILE_NAME
SG_NAME=$SG_NAME
EOF

echo "[INFO] Iniciando despliegue automatizado para la Clase 2..."
echo "Region: ${REGION}"
echo "Bucket S3 a crear: ${BUCKET_NAME}"

# 1. Validar y Crear Bucket S3
echo "[1/5] Creando Bucket S3..."
while true; do
    if aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
        echo "[WARNING] El bucket '$BUCKET_NAME' ya existe. Generando nuevo nombre..."
        RANDOM_HASH=$(head /dev/urandom | tr -dc 'a-z0-9' | head -c 5)
        BUCKET_NAME="galeria-aws-playa-vicente-$(date +%s)-${RANDOM_HASH}"
        echo "BUCKET_NAME=$BUCKET_NAME" >> .env.recursos_clase2
    else
        break
    fi
done

if [ "$REGION" = "us-east-1" ]; then
    aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$REGION" > /dev/null
else
    aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$REGION" \
        --create-bucket-configuration LocationConstraint="$REGION" > /dev/null
fi
echo "   [OK] Bucket S3 ('$BUCKET_NAME') creado exitosamente."

# 2. Crear IAM Role e Instance Profile
echo "[2/5] Creando IAM Role e Instance Profile..."
TRUST_POLICY='{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "Service": "ec2.amazonaws.com" },
      "Action": "sts:AssumeRole"
    }
  ]
}'

aws iam create-role --role-name "$ROLE_NAME" --assume-role-policy-document "$TRUST_POLICY" > /dev/null
aws iam attach-role-policy --role-name "$ROLE_NAME" --policy-arn "arn:aws:iam::aws:policy/AmazonS3FullAccess" > /dev/null
aws iam create-instance-profile --instance-profile-name "$PROFILE_NAME" > /dev/null
aws iam add-role-to-instance-profile --instance-profile-name "$PROFILE_NAME" --role-name "$ROLE_NAME" > /dev/null

echo "   [WAIT] Esperando 10 segundos a que IAM propague el nuevo Rol..."
sleep 10
echo "   [OK] IAM Role e Instance Profile creados."

# 3. Obtener VPC por defecto y crear Security Group
echo "[3/5] Configurando Security Group..."
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=isDefault,Values=true" --query "Vpcs[0].VpcId" --output text --region "$REGION")

SG_ID=$(aws ec2 create-security-group \
    --group-name "$SG_NAME" \
    --description "Security Group para Demo Clase 2 AWS UG Playa Vicente" \
    --vpc-id "$VPC_ID" \
    --query "GroupId" \
    --output text \
    --region "$REGION")

echo "SG_ID=$SG_ID" >> .env.recursos_clase2

# Permitir HTTP (puerto 80) y SSH (puerto 22)
aws ec2 authorize-security-group-ingress --group-id "$SG_ID" --protocol tcp --port 80 --cidr 0.0.0.0/0 --region "$REGION" > /dev/null
aws ec2 authorize-security-group-ingress --group-id "$SG_ID" --protocol tcp --port 22 --cidr 0.0.0.0/0 --region "$REGION" > /dev/null
echo "   [OK] Security Group ($SG_ID) configurado con puerto 80 y 22."

# 4. Obtener AMI de Amazon Linux 2023 con fallbacks
echo "[4/5] Obteniendo la ultima AMI de Amazon Linux 2023..."
AMI_ID=$(aws ssm get-parameters --names /aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64 --query "Parameters[0].Value" --output text --region "$REGION" 2>/dev/null || true)

if [ -z "$AMI_ID" ] || [ "$AMI_ID" = "None" ]; then
    echo "   [INFO] SSM no disponible, consultando via EC2 describe-images..."
    AMI_ID=$(aws ec2 describe-images \
        --owners amazon \
        --filters "Name=name,Values=al2023-ami-2023.*-x86_64" "Name=state,Values=available" \
        --query "sort_by(Images, &CreationDate)[-1].ImageId" \
        --output text \
        --region "$REGION" 2>/dev/null || true)
fi

# Fallback si no devuelve ninguna por permisos
if [ -z "$AMI_ID" ] || [ "$AMI_ID" = "None" ]; then
    AMI_ID="ami-0c101f26f1473446e"
fi

echo "   [OK] AMI ID seleccionada: $AMI_ID"

# 5. Generar User Data script y lanzar Instancia EC2
echo "[5/5] Lanzando Instancia EC2 con User Data e IAM Role..."
USER_DATA_FILE=$(mktemp)

cat << USERDATA_EOF > "$USER_DATA_FILE"
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
BUCKET_NAME = os.environ.get('BUCKET_NAME', '${BUCKET_NAME}')
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

export BUCKET_NAME="${BUCKET_NAME}"
(crontab -l 2>/dev/null; echo "@reboot export BUCKET_NAME=${BUCKET_NAME} && python3 /app.py &") | crontab -
python3 /app.py &
USERDATA_EOF

INSTANCE_ID=$(aws ec2 run-instances \
    --image-id "$AMI_ID" \
    --instance-type "t2.micro" \
    --iam-instance-profile Name="$PROFILE_NAME" \
    --security-group-ids "$SG_ID" \
    --user-data "file://$USER_DATA_FILE" \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=Servidor-Demo-Clase-2}]' \
    --query "Instances[0].InstanceId" \
    --output text \
    --region "$REGION")

rm -f "$USER_DATA_FILE"
echo "INSTANCE_ID=$INSTANCE_ID" >> .env.recursos_clase2
echo "   [OK] Instancia EC2 ($INSTANCE_ID) lanzada."
echo "   [WAIT] Esperando a que la instancia obtenga IP publica e inicie la app (30 segundos)..."

sleep 25

PUBLIC_IP=$(aws ec2 describe-instances \
    --instance-ids "$INSTANCE_ID" \
    --query "Reservations[0].Instances[0].PublicIpAddress" \
    --output text \
    --region "$REGION")

echo "PUBLIC_IP=$PUBLIC_IP" >> .env.recursos_clase2

echo ""
echo "=============================================================================="
echo "[EXITO] Despliegue completado con exito."
echo "URL de la aplicacion web: http://${PUBLIC_IP}"
echo "Bucket S3 asignado: ${BUCKET_NAME}"
echo "=============================================================================="
