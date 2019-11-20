run:
	ansible-playbook -i hosts ansible-pi.yml

init:
	ansible-galaxy role install -r requirements.yml
	ansible-galaxy collection install -r requirements.yml -p ./
