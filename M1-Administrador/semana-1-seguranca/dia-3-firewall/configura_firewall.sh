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

# --  Funcoes -- 

mostrar_uso() {
	echo -e "Uso: $0 [comando] [porta]"
	echo
	echo "comandos:"
	echo " add [porta] Adiciona uma porta TCp"
	echo " remove [porta] Remove uma porta TCP"
	echo "Exemplos:"
	echo " sudo $0 add 2222"
	echo " sudo $0 remove 2222"
	echo " sudo $0 add"
}

adicionar_porta() {
    local PORTA_PARA_ADICIONAR=$1
    echo -e "⇒ Configurando o firewall para PERMITIR a porta TCP ${PORTA_PARA_ADICIONAR}..."

    echo "1. Adicionando a porta ${PORTA_PARA_ADICIONAR}/tcp à configuração permanente..."
    firewall-cmd --permanent --add-port=${PORTA_PARA_ADICIONAR}/tcp > /dev/null 2>&1

    # Se a porta for 22 ou a porta SSH detectada, remove o serviço .
    PORTA_SSH_DETECTADA=$(grep -Eiv '^(#|^\s*$)' /etc/ssh/sshd_config | grep -i '^Port' | awk '{print $2}' | tail -n1)
    if [[ "$PORTA_PARA_ADICIONAR" == "22" || "$PORTA_PARA_ADICIONAR" == "$PORTA_SSH_DETECTADA" ]]; then
        echo "   (Detectado como porta SSH, removendo o serviço 'ssh' genérico para maior segurança...)"
        firewall-cmd --permanent --remove-service=ssh > /dev/null 2>&1
    fi

    echo "2. Recarregando o firewall para aplicar as mudanças..."
    firewall-cmd --reload

    echo -e "\n✔ Operação 'add' concluída com sucesso!"
}

remover_porta() {
    local PORTA_PARA_REMOVER=$1
    echo -e "⇒ Configurando o firewall para REMOVER a porta TCP ${PORTA_PARA_REMOVER}..."

    echo "1. Removendo a porta ${PORTA_PARA_REMOVER}/tcp da configuração permanente..."
    firewall-cmd --permanent --remove-port=${PORTA_PARA_REMOVER}/tcp > /dev/null 2>&1

    echo "2. Recarregando o firewall para aplicar as mudanças..."
    firewall-cmd --reload

    echo -e "\n Operação 'remove' concluída com sucesso!"
}

COMANDO=$1
PORTA=$2

case "$COMANDO" in
    add)
        if [[ -n "$PORTA" ]]; then
            # Modo Automação: usa a porta fornecida como segundo argumento.
            adicionar_porta "$PORTA"
       else
            # Modo Interativo: se nenhuma porta for fornecida, ajuda o usuário.
            echo -e "Modo Interativo de Adição de Porta..."
            read -p "Digite a porta TCP que deseja adicionar (ex: 8080): " PORTA_INTERATIVA
            if [[ -n "$PORTA_INTERATIVA" ]]; then
                adicionar_porta "$PORTA_INTERATIVA"
            else
                echo -e "Nenhuma porta fornecida. Operação cancelada."
                exit 1
            fi
        fi
        ;;

    remove)
        if [[ -n "$PORTA" ]]; then
            # Modo Automação: usa a porta fornecida como segundo argumento.
            remover_porta "$PORTA"
        else
            # Erro: O comando 'remove' exige uma porta.
            echo -e "ERRO: O comando 'remove' exige que você especifique uma porta."
            echo "Exemplo: sudo $0 remove 8080"
            exit 1
        fi
        ;;

    *)
        # comando inválido, mostra a ajuda.
        mostrar_uso
        exit 1
        ;;
esac

# --- Verificação Final ---
echo
echo -e "Verificação Final: Portas TCP Abertas Atualmente"
firewall-cmd --list-ports --permanent

