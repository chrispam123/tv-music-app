# TV Music App

Aplicación serverless OPTIMIZADA para Smart TV Samsung que reproduce música aleatoria de fondo mientras muestra reloj y fecha en pantalla pero complatible con cualquier dispositvo que utilice un navegador web moderno.

## Arquitectura

La aplicación utiliza arquitectura serverless completamente en AWS:

- **Frontend**: Sitio web estático (HTML/CSS/JS) servido mediante CloudFront con HTTPS
- **CDN**: CloudFront con Origin Access Control para acceso seguro a S3
- **Storage**: S3 bucket privado encriptado con KMS almacenando archivos MP3
- **Backend**: Lambda function (Python 3.11) que genera URLs pre-firmadas aleatorias
- **API**: API Gateway HTTP API exponiendo la función Lambda con CORS configurado
- **IaC**: Terraform para gestión completa de infraestructura como código

### Flujo de Datos
```
Usuario (TV Browser)
    → CloudFront (HTTPS)
    → S3 (Frontend estático)
    → JavaScript llama API Gateway
    → Lambda genera URL pre-firmada
    → Usuario descarga MP3 desde S3
    → Reproducción de audio en navegador
```

## Características de Seguridad

- HTTPS obligatorio mediante CloudFront con certificado SSL automático
- Bucket S3 de frontend completamente privado con Origin Access Control
- Bucket S3 de música encriptado con customer-managed KMS key
- URLs pre-firmadas con expiración de una hora para acceso temporal a archivos
- Configuración CORS apropiada para peticiones cross-origin seguras
- Políticas de IAM siguiendo principio de menor privilegio

## Requisitos Previos

- AWS CLI v2 instalado y configurado
- Terraform >= 1.7.4
- Python >= 3.11
- Cuenta AWS con permisos administrativos para bootstrap inicial

## Instalación y Despliegue

### 1. Configuración Inicial

Clona el repositorio:
```bash
git clone https://github.com/tu-usuario/tv-music-app.git
cd tv-music-app
```

### 2. Bootstrap de AWS

Ejecuta el script de bootstrap para crear recursos base necesarios (bucket de estado de Terraform, usuario IAM para desarrollo, políticas de permisos):
```bash
./scripts/bootstrap-aws.sh
```

Este script crea:
- Bucket S3 para estado de Terraform con versionado habilitado
- Usuario IAM `tv-music-app-developer` con credenciales
- Política IAM con permisos necesarios para gestionar la infraestructura

Configura el perfil AWS con las credenciales generadas:
```bash
aws configure --profile tv-music-dev
```

### 3. Despliegue de Infraestructura

Navega al entorno de desarrollo:
```bash
cd infraestructure/environments/dev
```

Inicializa Terraform:
```bash
terraform init
```

Revisa el plan de despliegue:
```bash
terraform plan
```

Aplica la infraestructura:
```bash
terraform apply
```

Terraform creará todos los recursos necesarios en AWS incluyendo buckets de S3, función Lambda, API Gateway, y distribución de CloudFront. El proceso toma entre 10-15 minutos principalmente debido a la propagación de CloudFront a ubicaciones edge globalmente.

### 4. Subir Archivos de Música

Crea una carpeta local para tus archivos MP3:
```bash
mkdir -p musica/
```

Copia tus archivos MP3 a esa carpeta, luego súbelos al bucket de música en S3:
```bash
aws s3 cp musica/ s3://tv-music-app-dev-music-storage/ --recursive --profile bootstrap-admin
```

Nota: Usa el perfil bootstrap-admin porque tiene permisos completos. El perfil tv-music-dev está limitado a operaciones de Terraform.

### 5. Acceder a la Aplicación

Después de que terraform apply complete exitosamente, obtén la URL pública de CloudFront:
```bash
terraform output frontend_website_url
```

Abre esa URL HTTPS en el navegador de tu Smart TV Samsung. La aplicación mostrará reloj, fecha, y un botón de play. Presiona el botón para iniciar reproducción de música aleatoria.

## Estructura del Proyecto
```
tv-music-app/
├── backend/
│   └── random-song-function/     # Código Lambda Python
│       ├── src/
│       │   └── handler.py        # Función principal
│       ├── tests/                # Tests unitarios
│       └── requirements*.txt     # Dependencias Python
├── frontend/
│   ├── index.html                # Estructura HTML
│   ├── css/styles.css            # Estilos para TV
│   └── js/app.js                 # Lógica de reloj y música
├── infraestructure/
│   ├── environments/
│   │   └── dev/                  # Configuración entorno desarrollo
│   └── modules/                  # Módulos Terraform reutilizables
│       ├── s3-music-storage/     # Bucket música encriptado
│       ├── lambda-random-song/   # Función Lambda
│       ├── api-gateway/          # API Gateway HTTP
│       ├── s3-frontend-hosting/  # Bucket frontend privado
│       └── cloudfront-distribution/  # CDN con HTTPS
├── scripts/
│   └── bootstrap-aws.sh          # Script setup inicial AWS
└── README.md
```

## Desarrollo Local

### Configuración de Entorno Python

Crea entorno virtual:
```bash
python3 -m venv .venv
source .venv/bin/activate
```

Instala dependencias de desarrollo:
```bash
cd backend/random-song-function
pip install pip-tools
pip-sync requirements-dev.txt
```

### Ejecutar Tests
```bash
pytest tests/ -v --cov=src
```

### Formateo y Linting
```bash
ruff check src/ tests/
ruff format src/ tests/
```

### Validación de Terraform
```bash
cd infraestructure/environments/dev
terraform fmt -recursive ../../
terraform validate
```

## CI/CD

El proyecto incluye workflows de GitHub Actions para integración y despliegue continuo:

- **CI**: Se ejecuta automáticamente en Pull Requests validando Terraform, Python, y seguridad
- **CD**: Se ejecuta manualmente con workflow_dispatch permitiendo despliegue controlado

Los workflows validan:
- Formato de código Terraform
- Sintaxis de configuración Terraform
- Tests unitarios de Python con cobertura
- Escaneo de seguridad con Trivy

## Costos Estimados

Para uso personal con un solo usuario:

- KMS Key: ~$1.00/mes (costo fijo)
- Lambda: <$0.01/mes (bajo volumen de invocaciones)
- S3: <$0.01/mes (pocos GB de almacenamiento)
- CloudFront: ~$0.01/mes (bajo tráfico, tier gratuito primer año)
- API Gateway: <$0.01/mes (pocas peticiones)

**Total estimado**: ~$1.00-1.05/mes

Con 1000 usuarios diarios el costo seguiría siendo menor a $10/mes debido a la naturaleza serverless de la arquitectura.

## Limpieza de Recursos

Para destruir toda la infraestructura y evitar costos:
```bash
# Vaciar bucket de música primero
aws s3 rm s3://tv-music-app-dev-music-storage/ --recursive --profile bootstrap-admin

# Destruir infraestructura con Terraform
cd infraestructure/environments/dev
terraform destroy

# Eliminar recursos de bootstrap manualmente desde consola AWS si ya no necesitas el proyecto
```

## Tecnologías Utilizadas

- **Infraestructura**: Terraform, AWS (S3, Lambda, API Gateway, CloudFront, KMS, IAM, CloudWatch)
- **Backend**: Python 3.11, boto3, botocore
- **Testing**: pytest, pytest-cov, moto
- **Frontend**: HTML5, CSS3, JavaScript (vanilla)
- **CI/CD**: GitHub Actions
- **Seguridad**: AWS KMS, Origin Access Control, HTTPS, IAM

## Licencia

MIT License - open

## Autor

mzk - DevOps y arquitectura serverless AWS
