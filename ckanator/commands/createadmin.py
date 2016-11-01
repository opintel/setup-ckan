import pexpect
import subprocess
from clint.textui import colored
from ckanator.dockerfiles.client import ClinetDockerBase


class CreateAdmin(ClinetDockerBase):
    """
    Clase que representa la accion de crear
    un CKAN admin mediante la CLI Tool
    """

    def run(self):
        """
        Metodo que crea un administrador
        en la instancia de ckan
        """
        password = self.options.get('--password')
        usuario = self.options.get('--username')

        if not usuario:
            self.errors = colored.red("Debes especificar un nombre de usuario para el administrador")
            return False

        if not password:
            self.errors = colored.red("Debes especificar el password del administrador")
            return False

        # Obtencion del contenedor CKAN
        docker_container = subprocess.Popen('docker ps --filter ancestor=ckan/ckan-plugins:latest -q', shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT).stdout.read()

        try:
            # Rutina de interaccion con al prompt del script
            child = pexpect.spawn('docker exec -it {1} /usr/lib/ckan/bin/paster --plugin=ckan sysadmin add {0} -c /project/development.ini'.format(usuario, docker_container))
            child.expect(['(?i)Create new user:'])
            child.sendline('y')
            child.expect('(?i)Password:')
            child.sendline(password)
            child.expect('(?i)Confirm password:')
            child.sendline(password)
        except:
            self.errors = colored.red("Algo salio mal. Por favor vuelve a intentarlo")
            self.errors += '{0} \n {1}'.format(child.after, child.before)
            return False

        print colored.green("Se ha creado el usuario {0}".format(usuario))
        return True
