import unittest
import docker
from ckanator import settings
from ckanator.commands.runserver import RunServer
from ckanator.commands.createadmin import CreateAdmin
from ckanator.commands.createneighborhood import CreageNeighborhood


class TestCreateNeighborhood(unittest.TestCase):
    def setUp(self):
        self.client_docker = docker.AutoVersionClient()

    def tearDown(self):
        self.client_docker = None

    def test_create_neighborhood(self):
        command = CreageNeighborhood(options={})
        # Verificar completado del proceso
        self.assertEqual(command.run(), True)

        # Verificar creacion de imagenes en Docker
        counter = 0
        for image in settings.DOCKER_IMAGES_DETAILS:
            docker_image = self.client_docker.images(name=image[0], quiet=True)
            counter += 1
            self.assertEqual(len(docker_image), 1)

        # Verificando el numero de imagenes creadas
        self.assertEqual(counter, 3)

    def test_run_server(self):
        # Verificar validaciones de parametros
        command = RunServer(options={})
        # Verificar parametros incompletos
        self.assertEqual(command.run(), False)

        command = RunServer(options={'--siteurl': 'http://localhost/'})
        # Verificar parametros incompletos
        self.assertEqual(command.run(), False)

        # Verificar validaciones de parametros
        command = RunServer(options={'--postgrespass': 'supersecurepass'})
        # Verificar parametros incompletos
        self.assertEqual(command.run(), False)

        # Verificar validaciones de parametros vacios
        command = RunServer(options={'--siteurl': '', '--postgrespass': ''})
        self.assertEqual(command.run(), False)

        # Verificar caso exitoso
        command = RunServer(options={'--siteurl': 'http://localhost/', '--postgrespass': 'supersecurepass'})
        self.assertEqual(command.run(), True)

        # Verificar caso de error porque ya existe el swarm
        command = RunServer(options={'--siteurl': 'http://localhost/', '--postgrespass': 'supersecurepass'})
        self.assertEqual(command.run(), False)
        self.assertEqual('This node is already part of a swarm. Use "docker swarm leave" to leave this swarm and join another one.' in command.errors, True)

    def test_create_admin(self):
        # Verificar validaciones de parametros
        command = CreateAdmin(options={})

        # Verificar parametros incompletos
        self.assertEqual(command.run(), False)

        command = CreateAdmin(options={'--username': 'admin_test'})
        # Verificar parametros incompletos
        self.assertEqual(command.run(), False)

        # Verificar validaciones de parametros
        command = CreateAdmin(options={'--password': 'supersecurepass'})
        # Verificar parametros incompletos
        self.assertEqual(command.run(), False)

        # Verificar validaciones de parametros vacios
        command = CreateAdmin(options={'--username': '', '--password': ''})
        self.assertEqual(command.run(), False)

        # Verificar caso exitoso
        command = CreateAdmin(options={'--username': 'admin_test', '--password': 'supersecurepass'})
        self.assertEqual(command.run(), True)

if __name__ == "__main__":
    unittest.main()
