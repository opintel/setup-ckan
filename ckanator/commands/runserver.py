# -*- coding: utf-8 -*-
import os
import subprocess
from clint.textui import colored
from ckanator.settings import CURRENT_PATH
from ckanator.dockerfiles.client import ClinetDockerBase


class RunServer(ClinetDockerBase):
    """
    Clase: Comando que levanta un SWARM Docker
    con el ambiente necesario para correr una
    instancia funcional de CKAN
    """
    def run(self):
        """
        Funcion que ejecuta un script bash
        para levantar SWARM que corre
        la instalacion de CKAN con
        sus servicios. Regresa True si todo es correcto
        False si algo falla en el proceso

        Return: Boolean
        """

        # Obtencion de los parametros
        site_url = self.options.get('--siteurl')
        postgres_password = self.options.get('--postgrespass')
        sh_script_path = os.path.join(CURRENT_PATH, 'dockerfiles/run-server.sh')

        # Validacion de los parametros
        if not site_url:
            self.errors = colored.red("Debes definir una url base. Ejemplo: http://localhost")
            return False

        if not postgres_password:
            self.errors = colored.red("Debes definir una contraseña para la Base de Datos")
            return False

        # Parametrizacion de las opciones a var envs
        os.environ.setdefault('SITE_CKAN_URL', site_url)
        os.environ.setdefault('POSTGRES_CKAN_PASSWORD_CLI', postgres_password)

        # Creacion del SWARM
        self.imprime_centrado('*')
        self.imprime_centrado("Comenzando creacion del SWARM CKAN")
        self.imprime_centrado('*')

        stdout = subprocess.check_output(['bash', sh_script_path], stderr=subprocess.STDOUT)

        # Borrado de variables de entorno
        os.environ.setdefault('SITE_CKAN_URL', '')
        os.environ.setdefault('POSTGRES_CKAN_PASSWORD_CLI', '')

        if not self.process_is_ok(stdout):
            return False

        self.imprime_centrado('Se han levantado los servicios exitosamente')
        return True

    def process_is_ok(self, output):
        """
        Funcion: Verifica que la salida
        del proceso de creacion del SWARM
        sea correcta

        if output in "Se han levantado los servicios exitosamente":
            return True
        elif output in "Ha ocurrido un error al levantar el SWARM":
            return False
        else:
        """
        for line in output.split('\n'):
            if 'Error response from daemon:' in line:
                self.errors = line.split('Error response from daemon:')[1]
                return False

        return True
