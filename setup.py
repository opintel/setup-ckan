from setuptools import setup
from kitcat import __version__


setup(
    name='kitcat',
    version=__version__,
    description='CLI Tool based in python to install a CKAN instance',
    url='https://github.com/opintel/setup-ckan',
    author='Francisco Vaquero',
    author_email='francisco@opi.la',
    keywords='ckan, cli',
    install_requires=['docopt', 'docker-py', 'clint', 'pexpect'],
    include_package_data=True,
    entry_points={
        'console_scripts': [
            'kitcat=kitcat.cli:main',
        ]
    }
)
