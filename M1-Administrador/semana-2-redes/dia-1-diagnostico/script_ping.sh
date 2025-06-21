#!/bin/bash

# script dia 1 - diagnostico

SERVIDOR="8.8.8.8"

#instalar dependencias e pacotes
echo "Instalando pacotes e dependencias"
sudo dnf install -y traceroute

# Executar ping
echo "2) Executando ping em $SERVIDOR"
echo "   (Pressione Ctrl+C para parar o ping)"
ping "$SERVIDOR"
echo

# Executar traceroute
echo "3) Executando traceroute em $SERVIDOR"
echo "   (Pressione Ctrl+C para parar o traceroute)"
traceroute "$SERVIDOR"
echo


echo " VERIFIQUE O DIAGNOSTICO "
