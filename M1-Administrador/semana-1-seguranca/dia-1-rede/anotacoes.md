# Dia 1: Análise de Rede e Setup Inicial do Servidor

## Objetivo

Realizar o primeiro contato com a VM `rocky-server`, executar atualizações essenciais e coletar informações críticas de rede para documentação e acesso futuro.

## Ações Executadas

1.  O sistema foi totalmente atualizado para garantir que todos os pacotes estejam com as últimas correções de segurança e bugs.
    ```bash
    sudo dnf update -y
    ```
2.  Foram instaladas ferramentas essenciais para administração e desenvolvimento.
    ```bash
    sudo dnf install git wget curl nano bash-completion -y
    ```
3.  As informações de rede foram coletadas.
    ```bash
    # Coleta de endereço IP
    ip a

    # Coleta de Gateway
    ip route
    ```

## Pontos-Chave e Aprendizados

- **DNF:** É o gerenciador de pacotes para o ecossistema RHEL (Rocky, CentOS, Fedora). É o equivalente ao `apt` do Debian/Ubuntu.
- **Rede:** Um servidor precisa de um **IP** para ser encontrado e um **Gateway** para se comunicar com a internet. Entender como encontrar essa informação é o primeiro passo de qualquer diagnóstico de rede.
- **Informações Coletadas:**
  - **Endereço IP:** `[SEU IP AQUI, ex: 192.168.1.105]`
  - **Gateway Padrão:** `[SEU GATEWAY AQUI, ex: 192.168.1.1]`

## Comandos de Verificação

- `dnf --version`: Confirma que o DNF está instalado.
- `ping 8.8.8.8`: Testa a conectividade com a internet, validando que o Gateway está funcionando.
