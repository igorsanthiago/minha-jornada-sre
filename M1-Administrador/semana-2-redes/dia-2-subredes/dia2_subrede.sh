#!/bin/bash

# Objetivo: detectar automaticamente sua máscara e mostrar:
#   - Endereço de Rede (Network)
#   - Máscara de Rede (Netmask)
#   - Endereço do Host (Address)
#   - Endereço de Broadcast (Broadcast)


# 1 Detecta seu IP via `ip a`
IP_CIDR=$(ip -4 addr show scope global \
         | grep inet \
         | head -1 \
         | awk '{print $2}')

if [ -z "$IP_CIDR" ]; then
  echo "Erro: nenhum IP IPv4 encontrado. Verifique sua conexão."
  exit 1
fi

# 2 Garante que ipcalc exista (instalação automática via DNF)
if ! command -v ipcalc &>/dev/null; then
  echo "ipcalc não encontrado. Instalando via DNF..."
  sudo dnf install -y ipcalc
fi

# 3 Executa ipcalc e captura campos
CALC=$(ipcalc "$IP_CIDR")
NETWORK=$(echo "$CALC" | awk '/Network:/   {print $2}')
NETMASK=$(echo "$CALC" | awk '/Netmask:/   {print $2}')
ADDRESS=$(echo "$CALC" | awk '/Address:/   {print $2}')
BROADCAST=$(echo "$CALC" | awk '/Broadcast:/ {print $2}')
HOSTMIN=$(echo "$CALC" | awk '/HostMin:/   {print $2}')
HOSTMAX=$(echo "$CALC" | awk '/HostMax:/   {print $2}')

# 4 Exibe com termos técnicos e significado
echo
echo "IPv4 Detectado:      $IP_CIDR"
echo
echo "Endereço de Rede:       $NETWORK"
echo "  (identifica o bloco de rede inteiro)"
echo
echo "Máscara de Rede:        $NETMASK"
echo "  (define quantos bits são rede vs. host)"
echo
echo "Endereço do Host:       $ADDRESS"
echo "  (identificador deste dispositivo na rede)"
echo
echo "Endereço de Broadcast:  $BROADCAST"
echo "  (destino para enviar pacotes a todos os hosts)"
echo
echo "Faixa de Hosts:         $HOSTMIN  até  $HOSTMAX"
echo "  (endereços válidos para dispositivos na sub-rede)"
echo

