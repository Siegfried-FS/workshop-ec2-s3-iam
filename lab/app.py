import os
from flask import Flask, request, redirect, render_template_string, send_from_directory
import boto3

app = Flask(__name__)
BUCKET_NAME = os.environ.get('BUCKET_NAME', 'galeria-aws-playa-vicente')

# Cliente de S3 (Intenta conectar si hay credenciales/IAM Role activo, sino mantiene la interfaz funcional localmente)
try:
    s3 = boto3.client('s3')
except Exception:
    s3 = None

HTML_TEMPLATE = '''
<!doctype html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>AWS User Group Playa Vicente | Muro de la Nube</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        :root {
            --bg-dark: #080c16;
            --surface: #10172a;
            --surface-hover: #1b253b;
            --surface-glass: rgba(16, 23, 42, 0.85);
            --border-color: #1e293b;
            --accent-purple: #a855f7;
            --accent-dark: #7c3aed;
            --accent-light: rgba(168, 85, 247, 0.15);
            --text-main: #ffffff;
            --text-muted: #cbd5e1;
            --gradient-btn: linear-gradient(135deg, #7c3aed, #a855f7);
            --gradient-text: linear-gradient(135deg, #e9d5ff, #c084fc, #a855f7);
            --spectrum-bar: linear-gradient(90deg, #5b21b6, #7c3aed, #a855f7, #60a5fa);
        }

        * { box-sizing: border-box; margin: 0; padding: 0; }

        body {
            font-family: 'Plus Jakarta Sans', -apple-system, BlinkMacSystemFont, sans-serif;
            background-color: var(--bg-dark);
            background-image: 
                radial-gradient(at 15% 15%, rgba(124, 58, 237, 0.12) 0px, transparent 50%),
                radial-gradient(at 85% 85%, rgba(168, 85, 247, 0.1) 0px, transparent 50%);
            background-attachment: fixed;
            color: var(--text-main);
            min-height: 100vh;
            padding: 20px 12px 40px 12px;
        }

        /* Top Spectrum Bar */
        .spectrum-bar {
            height: 4px;
            width: 100%;
            background: var(--spectrum-bar);
            position: fixed;
            top: 0;
            left: 0;
            z-index: 1000;
        }

        .container {
            max-width: 900px;
            margin: 10px auto 0 auto;
        }

        /* Glassmorphism Card Style */
        .glass-card {
            background: var(--surface-glass);
            backdrop-filter: blur(16px);
            -webkit-backdrop-filter: blur(16px);
            border: 1px solid var(--border-color);
            border-radius: 20px;
            box-shadow: 0 15px 35px rgba(0, 0, 0, 0.45);
        }

        /* Header Banner */
        .hero-header {
            padding: 28px 20px;
            text-align: center;
            margin-bottom: 20px;
        }

        .header-logo {
            max-width: 180px;
            height: auto;
            margin-bottom: 14px;
        }

        .badge-purple {
            display: inline-block;
            background: var(--accent-light);
            color: var(--accent-purple);
            font-size: 0.78rem;
            font-weight: 700;
            padding: 5px 14px;
            border-radius: 50px;
            border: 1px solid rgba(168, 85, 247, 0.3);
            margin-bottom: 12px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        h1 {
            font-size: 1.8rem;
            font-weight: 800;
            background: var(--gradient-text);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            margin-bottom: 8px;
            line-height: 1.2;
        }

        .subtitle {
            color: var(--text-muted);
            font-size: 0.9rem;
            max-width: 600px;
            margin: 0 auto 16px auto;
        }

        .tech-badges {
            display: flex;
            justify-content: center;
            gap: 8px;
            flex-wrap: wrap;
        }

        .badge-tech {
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid var(--border-color);
            color: var(--accent-purple);
            font-size: 0.75rem;
            font-weight: 600;
            padding: 4px 10px;
            border-radius: 8px;
        }

        /* Social Grid */
        .community-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(130px, 1fr));
            gap: 10px;
            margin-bottom: 20px;
        }

        .social-card {
            background: var(--surface);
            border: 1px solid var(--border-color);
            border-radius: 14px;
            padding: 12px;
            text-align: center;
            text-decoration: none;
            color: var(--text-main);
            font-weight: 600;
            font-size: 0.85rem;
            transition: all 0.25s ease;
        }

        .social-card:hover {
            border-color: var(--accent-purple);
            transform: translateY(-2px);
            color: var(--accent-purple);
        }

        /* Upload Section */
        .upload-section {
            padding: 24px 18px;
            margin-bottom: 24px;
            text-align: center;
            border: 2px dashed rgba(168, 85, 247, 0.3);
        }

        .upload-title {
            font-size: 1.15rem;
            font-weight: 700;
            color: #ffffff;
            margin-bottom: 6px;
        }

        .upload-desc {
            color: var(--text-muted);
            font-size: 0.85rem;
            margin-bottom: 18px;
        }

        .preview-container {
            display: none;
            margin: 12px auto 16px auto;
            max-width: 240px;
            border-radius: 12px;
            overflow: hidden;
            border: 2px solid var(--accent-purple);
        }

        .preview-img {
            width: 100%;
            height: 160px;
            object-fit: cover;
            display: block;
        }

        .file-label-btn {
            background: var(--accent-light);
            color: var(--accent-purple);
            border: 1px solid rgba(168, 85, 247, 0.4);
            padding: 11px 20px;
            border-radius: 10px;
            font-weight: 600;
            font-size: 0.88rem;
            cursor: pointer;
            display: inline-block;
            transition: all 0.2s;
            max-width: 100%;
            word-break: break-all;
        }

        .btn-upload-submit {
            background: var(--gradient-btn);
            color: #ffffff;
            border: none;
            padding: 14px 28px;
            border-radius: 12px;
            font-weight: 700;
            font-size: 0.95rem;
            cursor: pointer;
            width: 100%;
            max-width: 300px;
            margin-top: 14px;
            box-shadow: 0 6px 20px rgba(124, 58, 237, 0.3);
            transition: all 0.25s ease;
        }

        /* Gallery Grid */
        .gallery-container {
            padding: 24px 18px;
        }

        .gallery-topbar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 18px;
        }

        .gallery-heading {
            font-size: 1.1rem;
            font-weight: 700;
            color: #ffffff;
        }

        .btn-refresh {
            background: rgba(255, 255, 255, 0.05);
            color: var(--accent-purple);
            border: 1px solid var(--border-color);
            padding: 6px 14px;
            border-radius: 8px;
            font-weight: 600;
            font-size: 0.8rem;
            cursor: pointer;
        }

        .gallery-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
            gap: 14px;
        }

        .card-photo {
            background: var(--surface);
            border: 1px solid var(--border-color);
            border-radius: 14px;
            overflow: hidden;
            transition: all 0.25s ease;
        }

        .card-photo:hover {
            transform: translateY(-3px);
            border-color: var(--accent-purple);
        }

        .img-wrapper {
            width: 100%;
            height: 150px;
            overflow: hidden;
            background: #080c16;
            cursor: pointer;
        }

        .gallery-thumbnail {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .card-footer {
            padding: 10px 12px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .photo-filename {
            font-size: 0.75rem;
            color: var(--text-muted);
            font-weight: 600;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            max-width: 100px;
        }

        .view-btn {
            background: var(--accent-light);
            color: var(--accent-purple);
            border: 1px solid rgba(168, 85, 247, 0.3);
            border-radius: 6px;
            padding: 3px 8px;
            font-weight: 700;
            font-size: 0.72rem;
            cursor: pointer;
        }

        /* Modal Lightbox */
        .modal {
            display: none;
            position: fixed;
            z-index: 2000;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(8, 12, 22, 0.92);
            backdrop-filter: blur(12px);
            justify-content: center;
            align-items: center;
            padding: 15px;
            cursor: pointer;
        }

        .modal-content {
            max-width: 95%;
            max-height: 85vh;
            border-radius: 14px;
            border: 2px solid var(--accent-purple);
            object-fit: contain;
        }

        .close-hint {
            position: absolute;
            top: 20px;
            color: var(--text-muted);
            font-size: 0.85rem;
            background: rgba(16, 23, 42, 0.8);
            padding: 5px 14px;
            border-radius: 20px;
            border: 1px solid var(--border-color);
        }

        @media (max-width: 600px) {
            h1 { font-size: 1.45rem; }
            .hero-header { padding: 20px 14px; }
            .gallery-grid { grid-template-columns: repeat(auto-fill, minmax(135px, 1fr)); }
            .img-wrapper { height: 130px; }
        }
    </style>
</head>
<body>

<div class="spectrum-bar"></div>

<div class="container">

    <!-- Header Banner -->
    <header class="glass-card hero-header">
        <img src="/logo.png" alt="AWS User Group Playa Vicente Logo" class="header-logo" onerror="this.style.display='none'">
        <br>
        <span class="badge-purple">AWS User Group Playa Vicente</span>
        <h1>Muro de Fotos en Vivo — Clase 2</h1>
        <p class="subtitle">Sube tu captura de pantalla de la clase. Almacenamiento seguro en S3 mediante IAM Roles.</p>

        <div class="tech-badges">
            <span class="badge-tech">Amazon EC2</span>
            <span class="badge-tech">AWS IAM Role</span>
            <span class="badge-tech">Amazon S3</span>
        </div>
    </header>

    <!-- Community Social Links -->
    <div class="community-grid">
        <a href="https://www.meetup.com/aws-user-group-playa-vicente/" target="_blank" class="social-card">Meetup</a>
        <a href="https://chat.whatsapp.com/JBdSseny4XM65dGBHHDgwS" target="_blank" class="social-card">WhatsApp</a>
        <a href="https://t.me/AUGPlayaVicente" target="_blank" class="social-card">Telegram</a>
        <a href="https://www.youtube.com/channel/UCObJL_Id1HHsx1hg0aNISlw" target="_blank" class="social-card">YouTube</a>
    </div>

    <!-- Upload Section -->
    <section class="glass-card upload-section">
        <h2 class="upload-title">Sube tu captura de la Clase 2</h2>
        <p class="upload-desc">Tómale foto o captura a la transmisión en vivo y publícala en el muro colectivo.</p>

        <form method="post" enctype="multipart/form-data" action="/upload">
            <div class="preview-container" id="previewBox">
                <img id="imagePreview" class="preview-img" src="" alt="Vista previa">
            </div>

            <div>
                <label for="file-upload" class="file-label-btn" id="fileBtnLabel">
                    Seleccionar imagen...
                </label>
                <input id="file-upload" type="file" name="file" accept="image/*" required style="display:none;" onchange="previewFile(this)">
            </div>
            
            <button type="submit" class="btn-upload-submit">Publicar Foto en S3</button>
        </form>
    </section>

    <!-- Gallery Grid -->
    <section class="glass-card gallery-container">
        <div class="gallery-topbar">
            <h3 class="gallery-heading">Muro de la Comunidad ({{ imagenes|length }} fotos)</h3>
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
                <div style="grid-column: 1/-1; text-align: center; padding: 35px 10px; color: var(--text-muted);">
                    <p style="font-size: 1rem; margin-bottom: 4px;">No hay fotos en el muro.</p>
                    <p style="font-size: 0.82rem;">Sé el primero en subir tu captura.</p>
                </div>
            {% endfor %}
        </div>
    </section>

</div>

<!-- Modal Lightbox -->
<div id="photoModal" class="modal" onclick="closeModal()">
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

    function closeModal() {
        document.getElementById('photoModal').style.display = 'none';
    }

    setTimeout(function() { location.reload(); }, 180000);
</script>

</body>
</html>
'''

@app.route('/logo.png')
def serve_logo():
    return send_from_directory(os.path.dirname(os.path.abspath(__file__)), 'logo.png')

@app.route('/', methods=['GET'])
def index():
    imagenes = []
    if s3:
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
    if file and file.filename and s3:
        try:
            s3.upload_fileobj(file, BUCKET_NAME, file.filename)
        except Exception:
            pass
    return redirect('/')

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    try:
        app.run(host='0.0.0.0', port=port)
    except OSError:
        app.run(host='0.0.0.0', port=8085)
