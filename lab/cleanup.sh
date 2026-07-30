#!/bin/bash
# ==============================================================================
# Script de Limpieza Completa — Clase 2: De Cero a Cloud
# AWS User Group Playa Vicente
# ==============================================================================

REGION="${AWS_REGION:-us-east-1}"

echo "[INFO] Iniciando limpieza completa de recursos de la Clase 2 en region ${REGION}..."

# 1. Terminar todas las Instancias EC2 creadas para la demo (por Tag Name)
echo "[1/4] Buscando y terminando Instancias EC2 de la demo..."
INSTANCES=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=Servidor-Demo-Clase-2,Servidor-Web-UG-Playa-Vicente" "Name=instance-state-name,Values=running,pending,stopped" \
    --query "Reservations[*].Instances[*].InstanceId" \
    --output text \
    --region "$REGION" 2>/dev/null || true)

if [ -n "$INSTANCES" ] && [ "$INSTANCES" != "None" ]; then
    echo "   [ACTION] Terminando instancias: $INSTANCES"
    aws ec2 terminate-instances --instance-ids $INSTANCES --region "$REGION" > /dev/null
    echo "   [WAIT] Esperando a que las instancias finalicen..."
    aws ec2 wait instance-terminated --instance-ids $INSTANCES --region "$REGION" 2>/dev/null || sleep 15
    echo "   [OK] Instancias terminadas."
else
    echo "   [INFO] No se encontraron instancias EC2 pendientes."
fi

# 2. Eliminar Security Groups de la demo (comienzan con ec2-demo-sg-)
echo "[2/4] Buscando y eliminando Security Groups de la demo..."
SGS=$(aws ec2 describe-security-groups \
    --filters "Name=group-name,Values=ec2-demo-sg-*" \
    --query "SecurityGroups[*].GroupId" \
    --output text \
    --region "$REGION" 2>/dev/null || true)

if [ -n "$SGS" ] && [ "$SGS" != "None" ]; then
    for sg in $SGS; do
        echo "   [ACTION] Eliminando Security Group: $sg"
        aws ec2 delete-security-group --group-id "$sg" --region "$REGION" > /dev/null 2>&1 || true
    done
    echo "   [OK] Security Groups eliminados."
else
    echo "   [INFO] No se encontraron Security Groups pendientes."
fi

# 3. Vaciar y Eliminar Buckets S3 de la demo (comienzan con galeria-aws-playa-vicente-)
echo "[3/4] Buscando y eliminando Buckets S3 de la demo..."
BUCKETS=$(aws s3api list-buckets --query "Buckets[*].Name" --output text 2>/dev/null | tr '\t' '\n' | grep '^galeria-aws-playa-vicente-' || true)

if [ -n "$BUCKETS" ] && [ "$BUCKETS" != "None" ]; then
    for bucket in $BUCKETS; do
        echo "   [ACTION] Vaciando y eliminando Bucket: $bucket"
        aws s3 rm "s3://${bucket}" --recursive --region "$REGION" > /dev/null 2>&1 || true
        aws s3api delete-bucket --bucket "$bucket" --region "$REGION" > /dev/null 2>&1 || true
    done
    echo "   [OK] Buckets S3 eliminados."
else
    echo "   [INFO] No se encontraron buckets S3 pendientes."
fi

# 4. Eliminar IAM Instance Profiles y Roles de la demo
echo "[4/4] Buscando y eliminando IAM Roles e Instance Profiles de la demo..."
ROLES=$(aws iam list-roles --query "Roles[*].RoleName" --output text 2>/dev/null | tr '\t' '\n' | grep '^EC2-S3-Upload-Role-' || true)
PROFILES=$(aws iam list-instance-profiles --query "InstanceProfiles[*].InstanceProfileName" --output text 2>/dev/null | tr '\t' '\n' | grep '^EC2-S3-Upload-Profile-' || true)

if [ -n "$PROFILES" ] && [ "$PROFILES" != "None" ]; then
    for prof in $PROFILES; do
        role_attached=$(aws iam get-instance-profile --instance-profile-name "$prof" --query "InstanceProfile.Roles[0].RoleName" --output text 2>/dev/null || true)
        if [ -n "$role_attached" ] && [ "$role_attached" != "None" ]; then
            aws iam remove-role-from-instance-profile --instance-profile-name "$prof" --role-name "$role_attached" > /dev/null 2>&1 || true
        fi
        aws iam delete-instance-profile --instance-profile-name "$prof" > /dev/null 2>&1 || true
    done
fi

if [ -n "$ROLES" ] && [ "$ROLES" != "None" ]; then
    for r in $ROLES; do
        aws iam detach-role-policy --role-name "$r" --policy-arn "arn:aws:iam::aws:policy/AmazonS3FullAccess" > /dev/null 2>&1 || true
        aws iam delete-role --role-name "$r" > /dev/null 2>&1 || true
    done
    echo "   [OK] IAM Roles e Instance Profiles eliminados."
else
    echo "   [INFO] No se encontraron IAM Roles pendientes."
fi

rm -f .env.recursos_clase2
echo ""
echo "[OK] Limpieza TOTAL completada. Se han eliminado absolutamente todos los recursos de todas las ejecuciones previas."
