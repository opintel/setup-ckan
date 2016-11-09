kitcat
======

[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/mxabierto/kitcat?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

El kit de las ciudades abiertas instala automáticamente un paquete de herramientas para ser utilizadas en iniciativas locales de datos abiertos.

### Principios

1. Out-of-the-box & one-click-to-wisdom™ - un instalador realiza la tarea automáticamente, i.e. no será necesario abrir el manual.
2. Abierto y extensible - cualquiera puede agregar nueva funcionalidad a través de un _pull request_.
3. Configurable - la personalización y ajustes _ad hoc_ no serán un contratiempo y no modificarán el _core_.
4. KISS (keep it simple and small) - nos enfocamos en utilizar los menores recursos posibles.
5. No reinventamos ruedas - mejor utilizar recetas e instalaciones probadas por la comunidad que hacerla uno mismo.

### Requerimientos
- [Docker 1.12](https://www.docker.com/)
- [Python 2.7.10](https://www.python.org/downloads/)

### Instalacion

Para usar kitcat en su ambiente es necesario seguir los siguientes pasos.

**Nota: Los siguientes comandos de consola se basan en un sistema operativo Linux Debian Like. Pueden cambiar para otras distribuciones**

1. Se clona el repositorio github.

```sh
$ git clone git@github.com:mxabierto/kitcat.git
```
2. Se instala la aplicación junto con las dependencias faltantes.
```sh
$ bash kitcat/install.sh
```

### Uso
Para construir los componentes del ecosistema CKAN se debe correr el siguiente comando.

```sh
$ kitcat createneighborhood
```

Despues para levantar el ambiente se debe correr el siguiente comando:

```sh
$ kitcat runserver --postgrespass=<postgrespass> --siteurl=<host>
```

Donde *postgrespass* sera el password de la base de datos y *siteurl* la url base donde correra la instalación de CKAN (http://tudominio.com).

Para corroborar la instalación se debe revisar el puerto y host por medio del navegador.

En caso de algun error se deben correr los siguientes comandos y luego volver a correr el comando runserver.

```sh
$ docker swarm leave --force
$ docker network rm mynetckan
```

### Creacion de usuario master
Para la creación de un usuario master se deben tener instaladas y levantadas las instancias del ecosistema de CKAN previamente. Para corroborar la instalación y el estado de las instancias correr el siguiente comando que arrojará un listado de las instancias que estan corriendo actualmente en el host:

```sh
$ docker ps
```

Depues ejecutar el siguiente comando:

```sh
$ kitcat create admin --username=<username> --password=<password>
```

Una vez que se ejecuta el comando el sistema pedira por medio de preguntas los datos del nuevo administrador que deberan ser proporcionados para su creación.
