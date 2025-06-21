sudo nano /etc/ssh/sshd_config

# Mude a porta para algo não padrão, como 2222.
Port 2222
# Proíbe o login do superusuário.
PermitRootLogin no
# Força o uso de chaves criptográficas.
PasswordAuthentication no

E HABILITANDO O PUBKEYAUTHENTICATION

PubkeyAuthentication yes

use para criar a chave na maquina local: ssh-keygen -t ed25519 -C "email"

ssh-copy-id -t ./ssh/id_ed25519.pub -p 2222 usuariolinux@iplinux




