#!/bin/bash

# Script para configurar o firewall
# Dia 3 de estudos da semana 1 :)
# Ele detecta a porta usada pelo SSH e permite no firewall
# Também remove o serviço ssh padrão se estiver habilitado

#verifica se esta com sudo root
    if [ "$EUID" -ne 0 ]; then
        echo "Este script precisa ser executado como root. 
	Use: sudo $0"
        exit 1
    fi

# Verifica se o firewall-cmd está instalado
if ! command -v firewall-cmd &>/dev/null; then
    echo "firewall-cmd não encontrado. Irei instalar."
    sudo dnf install firewalld -y
fi

# Verifica se temos acesso ao arquivo sshd_config
if [[ ! -r /etc/ssh/sshd_config ]]; then
    echo "Erro: não consigo ler /etc/ssh/sshd_config. Rode como sudo!"
    exit 1
fi

echo "Verificando se o ssh está ativo..."

# Função para pegar a porta do ssh configurada
pegar_porta_ssh() {
    local porta
    porta=$(grep -E '^Port ' /etc/ssh/sshd_config | awk '{print $2}')
    
    # Se não encontrar, usamos a porta padrão 22
    if [[ -z "$porta" ]]; then
        echo "22"
    else
        echo "$porta"
    fi
}

# Armazena a porta atual configurada
PORTA_SSH=$(pegar_porta_ssh)

# Pergunta ao usuário se quer liberar essa porta ou outra
read -p "A porta SSH configurada no sistema é ${PORTA_SSH}. Deseja usá-la no firewall? (s/N): " resposta
if [[ "$resposta" =~ ^[Ss]$ ]]; then
    PORTA_NOVA="$PORTA_SSH"
else
    read -p "Digite a nova porta TCP para liberar no firewall (ex: 2222): " PORTA_NOVA
fi

echo "⇒ Porta selecionada: $PORTA_NOVA"

# 1: Remover o serviço ssh (porta 22 padrão) do firewall

echo "Verificando e removendo serviço SSH do firewall..."

# Runtime
if firewall-cmd --list-services | grep -qw ssh; then
    echo "Removendo ssh do runtime..."
    firewall-cmd --remove-service=ssh
else
    echo "SSH não está ativo no runtime."
fi

# Permanente
if firewall-cmd --list-services --permanent | grep -qw ssh; then
    echo "Removendo ssh do permanente..."
    firewall-cmd --permanent --remove-service=ssh
else
    echo "SSH não está ativo no permanente."
fi

# 2: Adicionar a nova porta ao firewall

echo "Verificando se a porta ${PORTA_NOVA}/tcp já está no firewall..."

# Runtime
if firewall-cmd --list-ports | grep -qw "${PORTA_NOVA}/tcp"; then
    echo "Porta ${PORTA_NOVA}/tcp já está ativa no runtime."
else
    echo "Adicionando porta no runtime..."
    firewall-cmd --add-port=${PORTA_NOVA}/tcp
fi

# Permanente
if firewall-cmd --list-ports --permanent | grep -qw "${PORTA_NOVA}/tcp"; then
    echo "Porta ${PORTA_NOVA}/tcp já está ativa no permanente."
else
    echo "Adicionando porta no permanente..."
    firewall-cmd --permanent --add-port=${PORTA_NOVA}/tcp
fi

# 3: Recarregar firewall
echo "Recarregando firewall para aplicar as mudanças..."
firewall-cmd --reload
sleep 2

echo " Configuração concluída com sucesso!"


