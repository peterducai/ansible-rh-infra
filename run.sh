#!/bin/bash

#ansible-playbook --connection=local --inventory 127.0.0.1, main.yml
ansible-playbook -i hosts main.yml -u root