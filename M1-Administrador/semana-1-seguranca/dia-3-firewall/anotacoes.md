# Dia 3: Anotações da Configuração do Firewall (firewalld)

## Objetivo

Configurar o firewall do `rocky-server` para permitir tráfego apenas na porta SSH customizada (2222), bloqueando o acesso à porta padrão e mantendo uma política de segurança restritiva.

## Estratégia de Configuração

A abordagem utilizada foi a de "segurança explícita", seguindo estes passos:

1.  **Remoção do Serviço Padrão:** O serviço genérico `ssh` do `firewalld`, que libera a porta 22, foi removido da configuração permanente. Isso evita que a porta padrão fique aberta e garante que nossa configuração seja a única fonte da verdade.

2.  **Adição de Porta Específica:** A porta `2222/tcp` foi explicitamente adicionada à configuração permanente. Isso garante que apenas a porta que nosso serviço SSH está realmente usando seja exposta.

3.  **Recarregamento Atômico:** Todas as mudanças foram feitas com a flag `--permanent`. Ao final, o comando `sudo firewall-cmd --reload` foi usado para aplicar todas as mudanças de uma só vez, garantindo que o firewall passe de um estado consistente para outro, sem janelas de vulnerabilidade.

## Comandos de Verificação

Para confirmar que a configuração está correta, use o seguinte comando:

sudo firewall-cmd --list-all
