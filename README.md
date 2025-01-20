# Apache Tomcat Installation Script

Este repositorio contiene un script de Bash para instalar Apache Tomcat 11 en un servidor Ubuntu 22.04.

## Descripción

El script `install_tomcat.sh` realiza las siguientes acciones:

1. Desactiva la pantalla de actualización del kernel.
2. Actualiza la lista de paquetes e instala actualizaciones.
3. Crea un usuario `tomcat` sin privilegios.
4. Instala JDK 21.
5. Descarga e instala Apache Tomcat 11.
6. Asigna permisos al usuario `tomcat` sobre la instalación de Tomcat.
7. Configura usuarios administrador en Tomcat.
8. Permite acceso externo a las aplicaciones de administración de Tomcat.
9. Crea y configura un servicio systemd para Tomcat.
10. Inicia y habilita el servicio de Tomcat para que se inicie automáticamente al arrancar el sistema.
