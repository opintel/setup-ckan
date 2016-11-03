wget -qO- https://get.docker.com/ | sh
wget https://bootstrap.pypa.io/ez_setup.py -O - | sudo python
curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py""| python
cd setup-ckan/
python setup.py develop
cd ..
ckanator