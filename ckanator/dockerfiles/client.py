import os
import docker


class ClinetDockerBase(object):
    """
    Clase base de un comando
    CLI en la herramienta
    ckanator
    """
    def __init__(self, *args, **kwargs):
        self.options = kwargs.get('options', {})
        self.args = args
        self.kwargs = kwargs
        self.client = docker.AutoVersionClient()
        self.responses = []
        self._errors = None

    @staticmethod
    def imprime_centrado(str):
        """
        Metodo: Imprime un mensaje centrado
        en base al ancho actual de la shell
        """
        rows, columns = os.popen('stty size', 'r').read().split()
        print str.center(int(columns), "*")

    def run(self):
        """
        Funcion: Logica del commando CLI
        Return: Boolean
        """
        raise NotImplementedError('You must implement the run() method yourself')

    @property
    def errors(self):
        return self._errors
