wget -qO- https://get.docker.com/ | sh
wget https://bootstrap.pypa.io/ez_setup.py -O - | sudo python
wget https://bootstrap.pypa.io/get-pip.py -O - | sudo python
cd kitcat/
python setup.py develop
cd ..
kitcat