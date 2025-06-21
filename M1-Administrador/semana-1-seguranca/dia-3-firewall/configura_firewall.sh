#!/bin/bash

# Script para configurar o firewall
# Dia 3 de estudos da semana 1 :)
# Ele detecta a porta usada pelo SSH e permite no firewall
# Também remove o serviço ssh padrão se estiver habilitado

#verifica se esta com sudo root
    if [ "$EUID" -ne 0 ]; then
        echo "ERRO: Este script precisa ser executado como root. 
	Use: sudo $0"
        exit 1
    fi

# Verifica se o firewall-cmd está instalado
if ! command -v firewall-cmd &>/dev/null; then
    echo "firewall-cmd não encontrado. Irei instalar."
    sudo dnf install firewalld -y
fi

# Função para pegar a porta do ssh configurada
pegar_porta_ssh() {
    local porta=$(grep -Eiv '^(#|^\s*$)' /etc/ssh/sshd_config | grep -i '^Port' | awk '{print $2}')
    # Se não encontrar, usamos a porta padrão 22
    if [[ -z "$porta" ]]; then
        echo "22"
    else
        echo "$porta"
    fi
}


PORTA_SSH=""

if [[ -n "$1" ]]; then
    # Modo Automação: usa o primeiro argumento da linha de comando
    PORTA_SSH="$1"
    echo -e "⇒ Modo Automação: Usando a porta ${PORTA_SSH} fornecida via argumento."
else
    # Modo Interativo: pergunta ao usuário
    PORTA_DETECTADA=$(pegar_porta_ssh)
    read -p "A porta SSH detectada é ${PORTA_DETECTADA}. Deseja usá-la? (S/n): " resposta
    if [[ ! "$resposta" =~ ^[Nn]$ ]]; then
        PORTA_SSH="$PORTA_DETECTADA"
    else
        read -p "Digite a nova porta TCP para liberar: " PORTA_SSH
    fi
fi

echo -e "⇒ Configurando o firewall para permitir a porta TCP ${PORTA_SSH}..."

# ETAPAS 
echo "1. Removendo o serviço 'ssh' padrão da configuração permanente..."
firewall-cmd --permanent --remove-service=ssh > /dev/null 2>&1 # Redireciona a saída para não poluir a tela

echo "2. Adicionando a porta ${PORTA_SSH}/tcp à configuração permanente..."
firewall-cmd --permanent --add-port=${PORTA_SSH}/tcp > /dev/null 2>&1

echo "3. Recarregando o firewall para aplicar as mudanças..."
firewall-cmd --reload

echo -e "\n Configuração concluída com sucesso!"
echo "Verificação da configuração atual:"
firewall-cmd --list-ports


