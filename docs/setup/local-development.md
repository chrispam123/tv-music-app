# Configuración de Entorno Local de Desarrollo

Esta guía te ayudará a configurar tu entorno de desarrollo local para trabajar en el proyecto tv-music-app.

## Prerequisitos

Antes de comenzar, asegúrate de tener instalado:

- **Sistema Operativo:** Linux (Ubuntu/Mint) o macOS
- **Git:** Para clonar el repositorio y gestionar versiones
- **Python 3.11.x:** Cualquier versión de parche de la rama 3.11 (3.11.8, 3.11.15, etc. son compatibles)
- **AWS CLI v2:** Para interactuar con servicios de AWS
- **Terraform 1.7+:** Para gestionar infraestructura como código

## Setup Automático (Recomendado)

El proyecto incluye un script que automatiza la mayor parte de la configuración:

\`\`\`bash
# 1. Clonar el repositorio
git clone <url-del-repo>
cd tv-music-app

# 2. Ejecutar el script de setup
./scripts/local-setup.sh
\`\`\`

El script validará prerequisitos, creará el entorno virtual de Python, instalará dependencias, y verificará la configuración de AWS y Terraform.

## Configuración de Credenciales de AWS

El script de setup detectará si necesitas configurar credenciales de AWS. Si no las tienes:

1. **Solicita credenciales al equipo de plataforma** (vía Slack, email, o tu canal interno)
2. **Configura el perfil de desarrollo:**

\`\`\`bash
aws configure --profile tv-music-dev
# AWS Access Key ID: [el que te proporcionaron]
# AWS Secret Access Key: [el que te proporcionaron]
# Default region: eu-west-1
# Default output format: json
\`\`\`

3. **Valida la conexión:**

\`\`\`bash
aws sts get-caller-identity --profile tv-music-dev
\`\`\`

## Flujo de Trabajo Diario

### Activar Entorno Virtual

Cada vez que trabajes en el proyecto, activa el entorno virtual:

\`\`\`bash
source .venv/bin/activate
\`\`\`

Verás `(.venv)` en tu prompt indicando que está activo.

### Desactivar Entorno Virtual

Cuando termines de trabajar:

\`\`\`bash
deactivate
\`\`\`

## Estructura del Proyecto

\`\`\`
tv-music-app/
├── backend/                  # Código de funciones Lambda
│   └── random-song-function/ # Lambda principal
├── docs/                     # Documentación del proyecto
├── infraestructure/          # Código de Terraform
│   └── environments/         # Configuraciones por entorno
│       ├── dev/              # Desarrollo
│       └── prod/             # Producción
├── scripts/                  # Scripts de automatización
└── .venv/                    # Entorno virtual (no commitear)
\`\`\`

## Troubleshooting

### "¿Qué versión exacta de Python necesito?"

El proyecto requiere Python 3.11.x (cualquier parche de la rama 3.11). Las versiones de parche dentro de 3.11 son completamente compatibles entre sí según el versionado semántico de Python. Si instalas vía `apt` usando el PPA deadsnakes, obtendrás la última versión de parche disponible, lo cual está perfectamente bien.

Si necesitas una versión de parche específica por alguna razón, considera usar `pyenv` en lugar de `apt`.


### "Python 3.11 not found"

Instala Python 3.11.8:

\`\`\`bash
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt update
sudo apt install python3.11 python3.11-venv python3.11-dev -y
\`\`\`

### "AWS credentials not configured"

Ver sección de Configuración de Credenciales de AWS arriba.

### "Terraform not initialized"

Navega al entorno de desarrollo e inicializa:

\`\`\`bash
cd infraestructure/environments/dev
terraform init
\`\`\`

## Próximos Pasos

Una vez que tu entorno esté configurado:

1. Lee la [documentación de arquitectura](../architecture/)
2. Revisa los [ADRs](../architecture/decisions/) para entender decisiones técnicas
3. Familiarízate con el flujo de branching (main, develop, feature/*)

## Ayuda

Si encuentras problemas no documentados aquí, contacta al equipo en el canal de Slack del proyecto.
\`\`\`

Guarda el archivo.

Ahora vamos a crear un README.md básico en la raíz del proyecto que sirva como punto de entrada:
````bash
nano README.md
````

Copia este contenido (conciso y directo):
````markdown
# TV Music App

Aplicación para Smart TVs Samsung que muestra reloj/fecha y reproduce música de fondo aleatoria.

## Stack Tecnológico

- **Backend:** AWS Lambda (Python 3.11)
- **Storage:** Amazon S3
- **API:** Amazon API Gateway
- **CDN:** Amazon CloudFront
- **IaC:** Terraform
- **CI/CD:** GitHub Actions (en desarrollo)

## Quick Start

\`\`\`bash
# Clonar repositorio
git clone <url-del-repo>
cd tv-music-app

# Configurar entorno local
./scripts/local-setup.sh

# Seguir instrucciones en pantalla
\`\`\`

## Documentación

- **[Setup Local](docs/setup/local-development.md)** - Configuración de entorno de desarrollo
- **[Arquitectura](docs/architecture/)** - Decisiones arquitectónicas (ADRs)
- **[Deployment](docs/runbooks/deployment.md)** - Procedimientos de deployment (TODO)

## Estructura del Proyecto

Ver [documentación de setup local](docs/setup/local-development.md#estructura-del-proyecto).

## Branching Strategy

- \`main\` - Producción (deployments manuales con aprobación)
- \`develop\` - Integración (CI automático en cada PR)
- \`feature/*\` - Nuevas funcionalidades
- \`fix/*\` - Correcciones de bugs
- \`chore/*\` - Tareas de mantenimiento

## Contacto

[Tu información de contacto o canal de Slack del equipo]
\`\`\`

Guarda el archivo.

Ahora valida que todo quedó bien estructurado. Ejecuta:
```bash
tree docs/ -L 2
ls -la *.md
```

Deberías ver la estructura de documentación y el README.md en la raíz.

Finalmente, vamos a hacer commit de todo este bloque de automatización y documentación. Verifica los cambios:
```bash
git status
```

Deberías ver:
- `scripts/local-setup.sh` (modificado)
- `docs/setup/local-development.md` (nuevo)
- `README.md` (nuevo)

Si todo está correcto, añade y commitea:
```bash
git add scripts/local-setup.sh docs/setup/local-development.md README.md
git commit -m "docs: Add local setup automation and documentation

- Create local-setup.sh script with idempotent environment configuration
- Add migration logic for legacy venv/ to .venv/ standard
- Document local development setup process
- Add project README with quick start guide
- Standardize on .venv naming convention for virtual environments"
```

Ejecuta el commit y confirma que quedó registrado:
```bash
git log --oneline -2
```

¿Todo correcto? Si sí, el Bloque Dos y Medio está **completo** y estamos listos para el Bloque Tres donde empezarás a escribir infraestructura real.
