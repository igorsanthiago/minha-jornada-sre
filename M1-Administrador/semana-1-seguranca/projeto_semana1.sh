#!/bin/bash

# --- Cores para o feedback ---
VERDE='\033[0;32m'
AMARELO='\033[1;33m'
VERMELHO='\033[0;31m'
AZUL='\033[0;34m'
NC='\033[0m' 

# --- Verificações Iniciais ---
if [ "$EUID" -ne 0 ]; then
    echo -e "${VERMELHO}ERRO: Este script precisa ser executado como root. Use: sudo $0${NC}"
    exit 1
fi

# --- Funções ---

mostrar_uso() {
    echo -e "${AZUL}Uso: $0 [comando] [argumento]${NC}"
    echo "gestão de firewall em servidores Rocky Linux."
    echo
    echo "Comandos:"
    echo "  menu             Executa o processo completo (updates, pacotes, firewall, fail2ban)."
    echo "  add     [porta]   Adiciona uma porta TCP ao firewall. Entra em modo interativo se a porta não for especificada."
    echo "  remover  <porta>   Remove uma porta TCP do firewall. A porta é obrigatória."
    echo
    echo "Exemplos:"
    echo "  sudo $0 menu"
    echo "  sudo $0 add 80"
    echo "  sudo $0 remover 80"
}

validar_porta() {
    local PORTA=$1
    if ! [[ "$PORTA" =~ ^[0-9]+$ ]] || (( PORTA < 1 || PORTA > 65535 )); then
        echo -e "${VERMELHO}ERRO: A porta '${PORTA}' é inválida. Deve ser um número entre 1 e 65535.${NC}"
        exit 1
    fi
}

adicionar_porta() {
    local PORTA_PARA_ADICIONAR=$1
    echo -e "${AZUL}--> Executando tarefa: Adicionar porta ${PORTA_PARA_ADICIONAR}${NC}"
    firewall-cmd --permanent --add-port=${PORTA_PARA_ADICIONAR}/tcp > /dev/null 2>&1
    echo "Porta ${PORTA_PARA_ADICIONAR}/tcp adicionada à configuração permanente."
}

remover_porta() {
    local PORTA_PARA_REMOVER=$1
    echo -e "${AZUL}--> Executando tarefa: Remover porta ${PORTA_PARA_REMOVER}${NC}"
    firewall-cmd --permanent --remove-port=${PORTA_PARA_REMOVER}/tcp > /dev/null 2>&1
    echo "Porta ${PORTA_PARA_REMOVER}/tcp removida da configuração permanente."
}

menu_projeto() {
    echo -e "${VERDE}### INICIANDO PROCESSO DE HARDENING INICIAL ###${NC}"

    # Passo 1: Atualização e Pacotes
    echo -e "\n${AZUL}[PASSO 1/3] Atualizando o sistema e instalando pacotes essenciais...${NC}"
    dnf update -y
    dnf install -y epel-release
    dnf install -y git wget curl nano bash-completion fail2ban

    # Passo 2: Configuração do Firewall para SSH
    # Nota: Vamos assumir a porta 2222 como nosso padrão de segurança.
while true; do
	numero=$(shuf -i 1000-9999 -n 1)
	if [[ "$numero" != "1234" && $((numero % 1000)) -ne 0 ]]; then
		break
	fi
done

    local PORTA_SSH="$numero"
    echo -e "\n${AZUL}[PASSO 2/3] Configurando o Firewall para a porta SSH segura (${PORTA_SSH})...${NC}"
    adicionar_porta "$PORTA_SSH"
    echo "   (Removendo o serviço 'ssh' genérico para maior segurança...)"
    firewall-cmd --permanent --remove-service=ssh > /dev/null 2>&1

    # Passo 3: Habilitando Serviços de Segurança
    echo -e "\n${AZUL}[PASSO 3/3] Habilitando e iniciando o Fail2Ban...${NC}"
    # Lembrete: Este passo assume que o /etc/fail2ban/jail.local já foi configurado para a porta correta.
    systemctl enable --now fail2ban

    echo -e "\n${VERDE}### HARDENING INICIAL CONCLUÍDO! ###${NC}"
    echo "Lembretes importantes:"
    echo " - A porta SSH ${PORTA_SSH} foi liberada no firewall."
    echo " - Verifique se o seu /etc/ssh/sshd_config está configurado para usar esta porta."
    echo " - Verifique se o seu /etc/fail2ban/jail.local está monitorando esta porta."
}


# --- Lógica Principal (O Roteador de Comandos) ---

COMANDO=$1
ARGUMENTO=$2

case "$COMANDO" in
    menu)
        menu_projeto
        ;;

    add)
        PORTA_FINAL=""
        if [[ -n "$ARGUMENTO" ]]; then
            PORTA_FINAL="$ARGUMENTO"
        else
            echo -e "${AZUL}Modo Interativo de Adição de Porta...${NC}"
            read -p "Digite a porta TCP que deseja adicionar (ex: 8080): " PORTA_FINAL
        fi
        
        if [[ -n "$PORTA_FINAL" ]]; then
            validar_porta "$PORTA_FINAL"
            adicionar_porta "$PORTA_FINAL"
        else
            echo -e "${AMARELO}Nenhuma porta fornecida. Operação cancelada.${NC}"
            exit 1
        fi
        ;;

    remover)
        if [[ -n "$ARGUMENTO" ]]; then
            validar_porta "$ARGUMENTO"
            remover_porta "$ARGUMENTO"
        else
            echo -e "${VERMELHO}ERRO: O comando 'remove' exige que você especifique uma porta.${NC}"
            mostrar_uso
            exit 1
        fi
        ;;

    *)
        # Se nenhum comando ou um comando inválido for fornecido, mostra a ajuda.
        mostrar_uso
        exit 1
        ;;
esac

# --- Verificação Final ---
echo -e "\n${AZUL}Recarregando o firewall para aplicar todas as mudanças...${NC}"
firewall-cmd --reload
echo
echo "=================================================="
echo -e "${AZUL}Verificação Final: Portas TCP Abertas Atualmente${NC}"
echo "=================================================="
firewall-cmd --list-ports --permanent
echo "=================================================="
