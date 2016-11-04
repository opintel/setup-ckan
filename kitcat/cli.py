#!/usr/bin/env python
"""
kitcat

Usage:
   kitcat createneighborhood
   kitcat runserver (--postgrespass=<postgrespass> --siteurl=<siteurl>)
   kitcat createadmin [--username=<username> --password=<password>]
"""
from docopt import docopt
from kitcat import __version__ as VERSION
from kitcat.commands import CreageNeighborhood, RunServer, CreateAdmin


def main():
    """
    Entry Point de la herramienta
    CLI de kitcat
    """
    # Parsear parametros de configuracion
    options = docopt(__doc__, version=VERSION)
    commands = {
        'createneighborhood': CreageNeighborhood,
        'runserver': RunServer,
        'createadmin': CreateAdmin
    }

    for key, value in options.iteritems():
        # Buscar el comando solicitado
        if commands.get(key) and value:
            command = commands.get(key)
            command = command(options=options)
            # Correr comando
            if command.run() is False:
                print command.errors
