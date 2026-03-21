# ADR 003: Diferir implementación de DynamoDB para locking de Terraform

**Estado:** Aceptado  
**Fecha:** 2025-03-20  
**Decisor:** Equipo de desarrollo (fase de aprendizaje individual)

## Contexto

Terraform soporta state locking mediante una tabla de DynamoDB cuando se usa S3 como backend remoto. El locking previene que múltiples procesos modifiquen el estado simultáneamente, lo cual podría causar corrupción del estado. Las mejores prácticas profesionales recomiendan habilitar locking en todos los entornos de producción y en equipos colaborativos.

El proyecto actualmente está en fase de desarrollo inicial con un solo desarrollador. No existe todavía pipeline de CI/CD automatizado que pueda ejecutar operaciones de Terraform concurrentemente con operaciones manuales del desarrollador.

El costo de una tabla de DynamoDB en modo on-demand para locking es microscópico, aproximadamente menos de un centavo mensual incluso con uso intensivo de desarrollo. El costo no es el factor decisivo, sino la complejidad del setup inicial.

## Decisión

Diferimos la creación de la tabla de DynamoDB para state locking hasta la fase de implementación de CI/CD. Durante la fase de desarrollo inicial, el backend de Terraform se configurará solo con el bucket de S3, sin especificar una tabla de DynamoDB para locking.

## Consecuencias

### Positivas

- Simplifica el bootstrap inicial del proyecto, reduciendo piezas móviles durante el aprendizaje de conceptos fundamentales de Terraform.
- Permite iterar rápidamente sin configuración adicional innecesaria en esta fase.
- Enseña explícitamente la diferencia entre setups mínimos y setups completos profesionales, reforzando comprensión de cuándo cada pieza es necesaria versus opcional.

### Negativas

- Terraform mostrará un warning en cada ejecución indicando que el locking está deshabilitado.
- Existe riesgo teórico de corrupción de estado si se ejecutan operaciones de Terraform concurrentemente, aunque este riesgo es mínimo con un solo desarrollador consciente del problema.
- Requiere disciplina manual de no ejecutar terraform apply en múltiples terminales simultáneamente.

### Mitigación

- El warning constante de Terraform sirve como recordatorio educativo de ser cuidadoso con operaciones concurrentes.
- La documentación del proyecto incluirá notas explicando que el locking está deshabilitado intencionalmente en esta fase.
- Cuando se implemente CI/CD, la tabla de DynamoDB se añadirá siguiendo estos pasos:
  1. Crear tabla de DynamoDB con AWS CLI o Terraform mismo.
  2. Actualizar configuración de backend en todos los entornos añadiendo parámetro dynamodb_table.
  3. Ejecutar terraform init -reconfigure en cada entorno para actualizar la configuración del backend.
  4. Documentar el cambio y el razonamiento en un nuevo ADR.

## Alternativas Consideradas

**Crear la tabla de DynamoDB desde el inicio:** Seguiría mejores prácticas profesionales completas y eliminaría warnings de Terraform, pero añade complejidad innecesaria en fase de aprendizaje individual sin CI/CD. Rechazada en favor de simplicidad incremental.

**Usar Terraform Cloud para backend:** Terraform Cloud proporciona locking integrado y backend gestionado sin necesidad de configurar S3 ni DynamoDB. Sin embargo, introduce dependencia en un servicio de terceros y requiere conectividad constante a internet. Rechazada en favor de aprender los fundamentos con AWS nativo que es más transparente y educativo.

## Referencias

- [Documentación de Terraform sobre State Locking](https://www.terraform.io/docs/language/state/locking.html)
- [AWS DynamoDB Pricing](https://aws.amazon.com/dynamodb/pricing/)

## Notas de Implementación

El script de bootstrap (`scripts/bootstrap-aws.sh`) incluirá comentarios explicando que la sección de creación de tabla de DynamoDB está comentada intencionalmente y por qué. La configuración del backend de Terraform incluirá comentarios similares señalando que el parámetro dynamodb_table está ausente por decisión consciente documentada en este ADR.

