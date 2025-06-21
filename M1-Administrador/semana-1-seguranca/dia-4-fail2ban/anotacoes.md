# Dia 4: Instalando o Segurança (Fail2Ban)

## Meu Objetivo Hoje

O objetivo era adicionar uma camada de defesa ativa no meu `rocky-server`. Depois de proteger o SSH com chaves e mudar a porta, eu queria um sistema que automaticamente bloqueasse IPs maliciosos que continuassem tentando forçar a entrada.

## O Que Eu Fiz (Passo a Passo)

1.  **Instalei o Repositório EPEL:** Aprendi que o Fail2Ban não vem nos repositórios padrão do Rocky, então o primeiro passo foi adicionar o EPEL (Extra Packages for Enterprise Linux), que me deu acesso a um universo de novos softwares confiáveis.
    sudo dnf install -y epel-release

2.  **Instalei o Fail2Ban:** Com o EPEL no lugar, a instalação foi simples.
    sudo dnf install -y fail2ban

3.  **Criei minha Configuração Local: **NUNCA editar `jail.conf`**. Então, eu o copiei para `jail.local`. Agora eu tenho um arquivo seguro para as minhas customizações que não será sobrescrito em atualizações futuras.
    sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

4.  **Configurei a "Jaula" do SSH:** Abri o meu novo `jail.local` e configurei a seção `[sshd]`. Foi aqui que eu disse ao Fail2Ban para prestar atenção na minha porta customizada.

## A Grande Sacada 

A sacada aqui foi entender como o Fail2Ban é inteligente. Eu não preciso dizer a ele *como* encontrar os erros de login ou *como* bloquear o IP no `firewalld`. Eu só preciso dizer a ele **o quê** proteger (a `[sshd]`), **onde** (na `port = 2222`), e garantir que esteja **ligado** (`enabled = true`). Ele cuida de todo o resto.

### Minha Configuração `[sshd]` no `jail.local`

[sshd]
enabled = true
port    = 2222
