import os

CURRENT_PATH = os.path.dirname(os.path.abspath(__file__))

DOCKER_FILES_PATH = (
    ('ckan/ckan-postgres', os.path.join(CURRENT_PATH, 'dockerfiles/ckan-postgres/Dockerfile'), os.path.join(CURRENT_PATH, 'dockerfiles/ckan-postgres')),
    ('ckan/ckan-solr', os.path.join(CURRENT_PATH, 'dockerfiles/ckan-solr/Dockerfile'), os.path.join(CURRENT_PATH, 'dockerfiles/ckan-solr')),
    ('ckan/ckan-base', os.path.join(CURRENT_PATH, 'dockerfiles/ckan/Dockerfile'), os.path.join(CURRENT_PATH, 'dockerfiles/ckan')),
    ('ckan/ckan-plugins', os.path.join(CURRENT_PATH, 'dockerfiles/ckan-plugins/Dockerfile'), os.path.join(CURRENT_PATH, 'dockerfiles/ckan-plugins')),
)

DOCKER_IMAGES_DETAILS = [
    ['ckan/ckan-postgres', 'ckan-postgres', {'POSTGRES_DB': 'ckan_default', 'POSTGRES_USER': 'ckan', 'USER_DATASTORE': 'ckan', 'DATABASE_DATASTORE': 'datastore_default', 'POSTGRES_PASSWORD': ''}, [5432], None, {5432: ('0.0.0.0', 5437)}],
    ['ckan/ckan-solr', 'ckan-solr', {}, [8080], None, {8080: ('0.0.0.0', 8080)}],
    ['ckan/ckan-plugins', 'ckan', {'INIT_DBS': 'true', 'TEST_DATA': 'false', 'CKAN_SITE_URL': ''}, [5000], [('ckan-postgres', 'postgres'), ('ckan-solr', 'solr')]]
]