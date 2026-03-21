#!/bin/bash
set -e
set -o pipefail

# Script de bootstrap para crear infraestructura base de Terraform
# Este script debe ejecutarse UNA SOLA VEZ al inicio del proyecto
# Requiere credenciales de administrador de AWS configuradas en el perfil 'bootstrap-admin'

echo "========================================="
echo "Terraform Backend Bootstrap"
echo "========================================="
echo ""
# Configuración - modifica estos valores según tu proyecto
PROJECT_NAME="tv-music-app"
AWS_REGION="eu-west-1"
AWS_PROFILE="bootstrap-admin"
TERRAFORM_STATE_BUCKET="${PROJECT_NAME}-terraform-state"
TERRAFORM_LOCK_TABLE="${PROJECT_NAME}-terraform-locks"
DEV_USER_NAME="${PROJECT_NAME}-developer"

echo "Configuración:"
echo "  Proyecto: ${PROJECT_NAME}"
echo "  Región: ${AWS_REGION}"
echo "  Perfil AWS: ${AWS_PROFILE}"
echo "  Bucket de estado: ${TERRAFORM_STATE_BUCKET}"
echo "  Tabla de locks: ${TERRAFORM_LOCK_TABLE}"
echo "  Usuario IAM: ${DEV_USER_NAME}"
echo ""
# Función para verificar si un comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Verificar que AWS CLI está instalado
if ! command_exists aws; then
    echo "ERROR: AWS CLI no está instalado"
    echo "Instala AWS CLI desde: https://aws.amazon.com/cli/"
    exit 1
fi

echo "Verificando credenciales de AWS..."
if ! aws sts get-caller-identity --profile "${AWS_PROFILE}" >/dev/null 2>&1; then
    echo "ERROR: No se pudieron verificar las credenciales de AWS"
    echo "Asegúrate de que el perfil '${AWS_PROFILE}' está configurado correctamente"
    exit 1
fi

ACCOUNT_ID=$(aws sts get-caller-identity --profile "${AWS_PROFILE}" --query Account --output text)
echo "✓ Conectado a la cuenta AWS: ${ACCOUNT_ID}"
echo ""
echo "Creando bucket de S3 para estado de Terraform..."

# Verificar si el bucket ya existe
if aws s3api head-bucket --bucket "${TERRAFORM_STATE_BUCKET}" --profile "${AWS_PROFILE}" 2>/dev/null; then
    echo "⚠ El bucket ${TERRAFORM_STATE_BUCKET} ya existe, saltando creación..."
else
    # Crear el bucket
    # Nota: eu-west-1 requiere LocationConstraint explícito
    aws s3api create-bucket \
        --bucket "${TERRAFORM_STATE_BUCKET}" \
        --region "${AWS_REGION}" \
        --create-bucket-configuration LocationConstraint="${AWS_REGION}" \
        --profile "${AWS_PROFILE}"
    
    echo "✓ Bucket creado: ${TERRAFORM_STATE_BUCKET}"
    
    # Habilitar versionado
    # Esto permite recuperar versiones anteriores del estado si algo sale mal
    aws s3api put-bucket-versioning \
        --bucket "${TERRAFORM_STATE_BUCKET}" \
        --versioning-configuration Status=Enabled \
        --profile "${AWS_PROFILE}"
    
    echo "✓ Versionado habilitado"
    
    # Habilitar encriptación del lado del servidor
    # Los archivos de estado pueden contener información sensible
    aws s3api put-bucket-encryption \
        --bucket "${TERRAFORM_STATE_BUCKET}" \
        --server-side-encryption-configuration '{
            "Rules": [{
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "AES256"
                }
            }]
        }' \
        --profile "${AWS_PROFILE}"
    
    echo "✓ Encriptación habilitada (AES256)"
    
    # Bloquear acceso público
    # El bucket de estado NUNCA debe ser público
    aws s3api put-public-access-block \
        --bucket "${TERRAFORM_STATE_BUCKET}" \
        --public-access-block-configuration \
            "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true" \
        --profile "${AWS_PROFILE}"
    
    echo "✓ Acceso público bloqueado"
fi

echo ""
echo "Tabla de DynamoDB para locking de Terraform..."
echo "⚠ La tabla de DynamoDB NO se crea en esta fase del proyecto"
echo "  Razón: Proyecto en desarrollo individual sin CI/CD"
echo "  Ver: docs/architecture/decisions/003-defer-dynamodb-locking.md"
echo "  La tabla se añadirá cuando se implemente CI/CD automatizado"
echo ""

echo "Creando usuario IAM para desarrollo..."

# Verificar si el usuario ya existe
if aws iam get-user --user-name "${DEV_USER_NAME}" --profile "${AWS_PROFILE}" 2>/dev/null; then
    echo "⚠ El usuario ${DEV_USER_NAME} ya existe, saltando creación..."
else
    # Crear el usuario
    aws iam create-user \
        --user-name "${DEV_USER_NAME}" \
        --tags Key=Project,Value="${PROJECT_NAME}" Key=Purpose,Value=Development \
        --profile "${AWS_PROFILE}"
    
    echo "✓ Usuario creado: ${DEV_USER_NAME}"
fi

# Crear o actualizar la política de permisos para el usuario
# Esta política permite gestionar la infraestructura del proyecto con Terraform
POLICY_NAME="${PROJECT_NAME}-terraform-policy"

cat > /tmp/terraform-policy.json << 'EOF'
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "TerraformStateAccess",
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject"
            ],
            "Resource": [
                "arn:aws:s3:::BUCKET_NAME",
                "arn:aws:s3:::BUCKET_NAME/*"
            ]
        },
        {
            "Sid": "ManageLambdaFunctions",
            "Effect": "Allow",
            "Action": [
                "lambda:*"
            ],
            "Resource": "*"
        },
        {
            "Sid": "ManageS3Buckets",
            "Effect": "Allow",
            "Action": [
                "s3:*"
            ],
            "Resource": "*"
        },
        {
            "Sid": "ManageAPIGateway",
            "Effect": "Allow",
            "Action": [
                "apigateway:*"
            ],
            "Resource": "*"
        },
        {
            "Sid": "ManageCloudFront",
            "Effect": "Allow",
            "Action": [
                "cloudfront:*"
            ],
            "Resource": "*"
        },
        {
            "Sid": "ManageIAMRoles",
            "Effect": "Allow",
            "Action": [
                "iam:CreateRole",
                "iam:DeleteRole",
                "iam:GetRole",
                "iam:PassRole",
                "iam:AttachRolePolicy",
                "iam:DetachRolePolicy",
                "iam:PutRolePolicy",
                "iam:DeleteRolePolicy",
                "iam:GetRolePolicy",
                "iam:ListRolePolicies",
                "iam:ListAttachedRolePolicies",
                "iam:TagRole",
                "iam:UntagRole"
            ],
            "Resource": "arn:aws:iam::ACCOUNT_ID:role/${PROJECT_NAME}-*"
        },
        {
            "Sid": "ManageCloudWatchLogs",
            "Effect": "Allow",
            "Action": [
                "logs:*"
            ],
            "Resource": "*"
        }
    ]
}
EOF

# Reemplazar placeholders en la política
sed -i "s/BUCKET_NAME/${TERRAFORM_STATE_BUCKET}/g" /tmp/terraform-policy.json
sed -i "s/ACCOUNT_ID/${ACCOUNT_ID}/g" /tmp/terraform-policy.json

echo "Creando política de permisos..."

# Verificar si la política ya existe y crearla o actualizarla
POLICY_ARN="arn:aws:iam::${ACCOUNT_ID}:policy/${POLICY_NAME}"

if aws iam get-policy --policy-arn "${POLICY_ARN}" --profile "${AWS_PROFILE}" 2>/dev/null; then
    # La política existe, obtener la versión por defecto actual
    echo "⚠ La política ${POLICY_NAME} ya existe, creando nueva versión..."
    
    # Crear una nueva versión de la política
    aws iam create-policy-version \
        --policy-arn "${POLICY_ARN}" \
        --policy-document file:///tmp/terraform-policy.json \
        --set-as-default \
        --profile "${AWS_PROFILE}"
    
    echo "✓ Política actualizada con nueva versión"
else
    # La política no existe, crearla
    aws iam create-policy \
        --policy-name "${POLICY_NAME}" \
        --policy-document file:///tmp/terraform-policy.json \
        --description "Permisos para gestionar infraestructura del proyecto ${PROJECT_NAME} con Terraform" \
        --tags Key=Project,Value="${PROJECT_NAME}" \
        --profile "${AWS_PROFILE}"
    
    echo "✓ Política creada: ${POLICY_NAME}"
fi

# Adjuntar la política al usuario
if aws iam list-attached-user-policies --user-name "${DEV_USER_NAME}" --profile "${AWS_PROFILE}" | grep -q "${POLICY_NAME}"; then
    echo "⚠ La política ya está adjunta al usuario"
else
    aws iam attach-user-policy \
        --user-name "${DEV_USER_NAME}" \
        --policy-arn "${POLICY_ARN}" \
        --profile "${AWS_PROFILE}"
    
    echo "✓ Política adjuntada al usuario ${DEV_USER_NAME}"
fi

# Limpiar archivo temporal
rm -f /tmp/terraform-policy.json

echo ""
echo "========================================="
echo "Bootstrap completado exitosamente"
echo "========================================="
echo ""
echo "Siguiente paso: Crear credenciales de acceso para el usuario de desarrollo"
echo ""
echo "Ejecuta estos comandos para crear las credenciales:"
echo "  aws iam create-access-key --user-name ${DEV_USER_NAME} --profile ${AWS_PROFILE}"
echo ""
echo "Luego configura las credenciales en tu perfil 'tv-music-dev':"
echo "  aws configure --profile tv-music-dev"
echo ""
echo "Recursos creados:"
echo "  - Bucket S3: ${TERRAFORM_STATE_BUCKET}"
echo "  - Usuario IAM: ${DEV_USER_NAME}"
echo "  - Política IAM: ${POLICY_NAME}"
echo ""



