#!/usr/bin/env python
"""
ckanator

Usage:
   ckanator createneighborhood
   ckanator runserver (--postgrespass=<postgrespass> --siteurl=<siteurl>)
   ckanator createadmin [--username=<username> --password=<password>]
"""
from inspect import getmembers, isclass
from docopt import docopt
from ckanator import __version__ as VERSION


def main():
    """
    Entry Point de la herramienta
    CLI de ckanator
    """
    from ckanator import commands
    # Parsear parametros de configuracion
    options = docopt(__doc__, version=VERSION)

    for key, value in options.iteritems():
        # Buscar el comando solicitado
        if hasattr(commands, key) and value:
            module = getattr(commands, key)
            commands = getmembers(module, isclass)
            # Se busca el comando en las funciones
            command = [command[1] for command in commands if command[0] != 'ClinetDockerBase'][0]
            command = command(options=options)
            # Correr comando
            if command.run() is False:
                print command.erros
