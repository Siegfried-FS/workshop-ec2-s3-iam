import * as cdk from 'aws-cdk-lib';
import * as ec2 from 'aws-cdk-lib/aws-ec2';
import { Construct } from 'constructs';
import { readFileSync } from 'fs';
import { join } from 'path';

/**
 * Stack de Infraestructura para Vaultwarden
 * 
 * Este stack crea toda la infraestructura necesaria para ejecutar Vaultwarden:
 * - VPC (usa la VPC por defecto de AWS)
 * - Security Group con reglas para SSH, HTTP y HTTPS
 * - Instancia EC2 con Amazon Linux 2
 * - Script de instalación automática (User Data)
 * - Elastic IP para IP pública estática
 * - Volumen EBS persistente
 * 
 * Uso:
 *   cdk deploy    - Desplegar la infraestructura
 *   cdk destroy   - Eliminar todos los recursos
 *   cdk diff      - Ver cambios antes de desplegar
 *   cdk synth     - Generar template de CloudFormation
 */
export class VaultwardenStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // ========================================================================
    // 1. OBTENER LA VPC POR DEFECTO
    // ========================================================================
    // Usamos la VPC por defecto para simplificar el workshop
    // En producción, considera crear una VPC personalizada
    const vpc = ec2.Vpc.fromLookup(this, 'DefaultVPC', {
      isDefault: true,
    });

    // ========================================================================
    // 2. CREAR SECURITY GROUP
    // ========================================================================
    // El Security Group actúa como firewall para la instancia EC2
    const securityGroup = new ec2.SecurityGroup(this, 'VaultwardenSecurityGroup', {
      vpc,
      securityGroupName: 'vaultwarden-sg-cdk',
      description: 'Security Group para Vaultwarden (creado con CDK)',
      allowAllOutbound: true, // Permite todo el tráfico saliente
    });

    // Regla 1: SSH (puerto 22)
    // Permite conexión SSH desde cualquier IP
    // En producción, restringe esto a IPs específicas
    securityGroup.addIngressRule(
      ec2.Peer.anyIpv4(),
      ec2.Port.tcp(22),
      'Permitir SSH desde cualquier IP'
    );

    // Regla 2: HTTP (puerto 80)
    // Permite acceso web a Vaultwarden
    securityGroup.addIngressRule(
      ec2.Peer.anyIpv4(),
      ec2.Port.tcp(80),
      'Permitir HTTP para acceso web a Vaultwarden'
    );

    // Regla 3: HTTPS (puerto 443)
    // Para futuro uso con certificados SSL/TLS
    securityGroup.addIngressRule(
      ec2.Peer.anyIpv4(),
      ec2.Port.tcp(443),
      'Permitir HTTPS para acceso seguro'
    );

    // ========================================================================
    // 3. OBTENER LA AMI DE AMAZON LINUX 2
    // ========================================================================
    // Busca la AMI más reciente de Amazon Linux 2
    const ami = ec2.MachineImage.latestAmazonLinux2({
      cpuType: ec2.AmazonLinuxCpuType.X86_64,
    });

    // ========================================================================
    // 4. CREAR PAR DE CLAVES (REFERENCIA)
    // ========================================================================
    // Nota: CDK no puede crear pares de claves SSH automáticamente
    // Debes crear el par de claves manualmente antes de desplegar:
    // 1. Ve a EC2 → Key Pairs en la consola de AWS
    // 2. Crea un par de claves llamado "vaultwarden-key-cdk"
    // 3. Descarga el archivo .pem
    // 
    // O usa un par de claves existente cambiando el nombre aquí
    const keyName = 'vaultwarden-key-cdk';

    // ========================================================================
    // 5. LEER EL SCRIPT DE INSTALACIÓN
    // ========================================================================
    // Lee el script de instalación desde el archivo
    // Este es el mismo script de la Fase 2
    const userDataScript = readFileSync(
      join(__dirname, '../../fase-2-script/install-vaultwarden.sh'),
      'utf8'
    );

    // Crear objeto UserData de CDK
    const userData = ec2.UserData.forLinux();
    // Agregar el script completo
    userData.addCommands(userDataScript);

    // ========================================================================
    // 6. CREAR INSTANCIA EC2
    // ========================================================================
    const instance = new ec2.Instance(this, 'VaultwardenInstance', {
      // Configuración básica
      instanceType: ec2.InstanceType.of(
        ec2.InstanceClass.T2,
        ec2.InstanceSize.MICRO
      ),
      machineImage: ami,
      vpc,
      vpcSubnets: {
        subnetType: ec2.SubnetType.PUBLIC, // Usa subnet pública
      },
      securityGroup,
      keyName, // Par de claves SSH
      
      // Configuración de almacenamiento
      blockDevices: [
        {
          deviceName: '/dev/xvda', // Dispositivo raíz
          volume: ec2.BlockDeviceVolume.ebs(8, {
            volumeType: ec2.EbsDeviceVolumeType.GP3, // SSD de propósito general
            deleteOnTermination: false, // IMPORTANTE: Mantener datos al terminar instancia
            encrypted: true, // Encriptar el volumen
          }),
        },
      ],
      
      // Script de instalación
      userData,
      
      // Configuración adicional
      instanceName: 'Vaultwarden-CDK',
      requireImdsv2: true, // Seguridad: Requiere IMDSv2
    });

    // Tags adicionales para la instancia
    cdk.Tags.of(instance).add('Name', 'Vaultwarden-CDK');
    cdk.Tags.of(instance).add('Application', 'Vaultwarden');
    cdk.Tags.of(instance).add('ManagedBy', 'CDK');

    // ========================================================================
    // 7. CREAR Y ASOCIAR ELASTIC IP
    // ========================================================================
    // Elastic IP proporciona una IP pública estática
    // La IP no cambia si detienes y vuelves a iniciar la instancia
    const eip = new ec2.CfnEIP(this, 'VaultwardenEIP', {
      domain: 'vpc',
      tags: [
        {
          key: 'Name',
          value: 'Vaultwarden-EIP-CDK',
        },
      ],
    });

    // Asociar la Elastic IP a la instancia
    new ec2.CfnEIPAssociation(this, 'VaultwardenEIPAssociation', {
      eip: eip.ref,
      instanceId: instance.instanceId,
    });

    // ========================================================================
    // 8. OUTPUTS (SALIDAS)
    // ========================================================================
    // Estos valores se mostrarán después del despliegue
    // Son útiles para acceder a la instancia y a Vaultwarden

    // Output 1: ID de la instancia
    new cdk.CfnOutput(this, 'InstanceId', {
      value: instance.instanceId,
      description: 'ID de la instancia EC2',
      exportName: 'VaultwardenInstanceId',
    });

    // Output 2: IP pública (Elastic IP)
    new cdk.CfnOutput(this, 'PublicIP', {
      value: eip.ref,
      description: 'IP pública de Vaultwarden (Elastic IP)',
      exportName: 'VaultwardenPublicIP',
    });

    // Output 3: URL de acceso
    new cdk.CfnOutput(this, 'VaultwardenURL', {
      value: `http://${eip.ref}`,
      description: 'URL para acceder a Vaultwarden',
      exportName: 'VaultwardenURL',
    });

    // Output 4: Comando SSH
    new cdk.CfnOutput(this, 'SSHCommand', {
      value: `ssh -i ~/.ssh/${keyName}.pem ec2-user@${eip.ref}`,
      description: 'Comando para conectarse por SSH',
      exportName: 'VaultwardenSSHCommand',
    });

    // Output 5: Security Group ID
    new cdk.CfnOutput(this, 'SecurityGroupId', {
      value: securityGroup.securityGroupId,
      description: 'ID del Security Group',
      exportName: 'VaultwardenSecurityGroupId',
    });

    // Output 6: Zona de disponibilidad
    new cdk.CfnOutput(this, 'AvailabilityZone', {
      value: instance.instanceAvailabilityZone,
      description: 'Zona de disponibilidad de la instancia',
      exportName: 'VaultwardenAvailabilityZone',
    });

    // ========================================================================
    // 9. NOTAS IMPORTANTES
    // ========================================================================
    // 
    // Antes de desplegar:
    // 1. Instala Node.js (versión 14 o superior)
    // 2. Instala AWS CLI y configúralo: aws configure
    // 3. Instala las dependencias: npm install
    // 4. Crea el par de claves "vaultwarden-key-cdk" en la consola de AWS
    // 5. Bootstrap CDK (solo la primera vez): cdk bootstrap
    // 
    // Para desplegar:
    //   npm run build
    //   cdk deploy
    // 
    // Para eliminar:
    //   cdk destroy
    // 
    // Costos:
    // - EC2 t2.micro: ~$8-10/mes (gratis en Free Tier)
    // - Elastic IP: Gratis mientras esté asociada
    // - EBS 8GB: ~$0.80/mes (gratis en Free Tier)
    // 
    // Seguridad:
    // - Este despliegue es para fines educativos
    // - Para producción, configura HTTPS, backups, y restringe SSH
    // 
    // ========================================================================
  }
}
