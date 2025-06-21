# Dia 2: Hardening do Serviço SSH

## Objetivo

Aumentar drasticamente a segurança da porta de entrada do servidor (`sshd`), desabilitando métodos de autenticação fracos e reduzindo a superfície de ataque.

## Ações Executadas

O arquivo de configuração `/etc/ssh/sshd_config` foi modificado para aplicar as seguintes políticas:

1.  **Mudança de Porta:**
    - **De:** `Port 22`
    - **Para:** `Port 2222`
    - **Justificativa:** Evitar a varredura de bots automatizados que visam a porta padrão 22.

2.  **Desabilitar Login do Root:**
    - **Configuração:** `PermitRootLogin no`
    - **Justificativa:** Forçar o uso de um usuário não-privilegiado para o login inicial, exigindo uma elevação de privilégio (`sudo`) para tarefas administrativas. Isso cria uma camada extra de segurança e melhora a auditoria.

3.  **Forçar Autenticação por Chave:**
    - **Configuração:** `PasswordAuthentication no`
    - **Justificativa:** Desabilita o método de login com senha, que é vulnerável a ataques de força bruta. A autenticação por chave pública/privada é criptograficamente muito mais segura.

## Pontos-Chave e Aprendizados

- A segurança de um serviço é definida em seu arquivo de configuração.
- **NUNCA** feche uma sessão SSH ativa antes de testar a nova configuração em um novo terminal. Isso evita que você se tranque para fora do servidor.
- O uso de um arquivo `~/.ssh/config` no cliente local agiliza muito o trabalho, criando apelidos para conexões frequentes.

## Comandos de Verificação

- `sudo systemctl status sshd`: Verifica se o serviço SSH está ativo após a reinicialização.
- `ss -tlpn | grep sshd`: Mostra em qual porta o serviço `sshd` está escutando. A saída deve mostrar a porta `2222`.
- Tentativa de login no novo terminal: `ssh -p 2222 usuario@ip`.
