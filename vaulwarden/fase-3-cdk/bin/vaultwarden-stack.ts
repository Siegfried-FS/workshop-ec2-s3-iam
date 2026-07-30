#!/usr/bin/env node

/**
 * Punto de Entrada de la Aplicación CDK para Vaultwarden
 * 
 * Este archivo es el punto de entrada principal de la aplicación CDK.
 * Crea la aplicación CDK y el stack de infraestructura de Vaultwarden.
 * 
 * Uso:
 *   npm install
 *   npm run build
 *   cdk deploy
 * 
 * Para destruir:
 *   cdk destroy
 */

import 'source-map-support/register';
import * as cdk from 'aws-cdk-lib';
import { VaultwardenStack } from '../lib/vaultwarden-stack';

// Crear la aplicación CDK
const app = new cdk.App();

// Crear el stack de Vaultwarden
// El stack contiene toda la infraestructura necesaria:
// - VPC (usa la VPC por defecto)
// - Security Group (con reglas para puertos 22, 80, 443)
// - Instancia EC2 (Amazon Linux 2, t2.micro)
// - Elastic IP (IP pública estática)
// - User Data (script de instalación automática)
new VaultwardenStack(app, 'VaultwardenStack', {
  // Configuración del stack
  description: 'Stack de infraestructura para Vaultwarden en EC2',
  
  // Tags que se aplicarán a todos los recursos
  tags: {
    Project: 'Vaultwarden-Workshop',
    Environment: 'Development',
    ManagedBy: 'CDK',
    Workshop: 'AWS-User-Group'
  },
  
  // Configuración de la región y cuenta
  // Si no se especifica, usa la configuración por defecto de AWS CLI
  env: {
    account: process.env.CDK_DEFAULT_ACCOUNT,
    region: process.env.CDK_DEFAULT_REGION,
  },
});

// Sintetizar el template de CloudFormation
// Esto genera el archivo JSON que AWS CloudFormation usará
app.synth();
