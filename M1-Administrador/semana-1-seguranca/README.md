# Módulo 1 | Semana 1: Kit de Hardening e Ferramentas para Servidor Rocky Linux 9

**Autor:** Igor Santhiago
**Data de Conclusão:** 21 de junho de 2025

---

## 1. Resumo do Projeto

Este projeto documenta os passos e automações para aplicar uma linha de base de segurança (hardening) em um servidor Rocky Linux 9. O resultado final é um servidor robusto e uma ferramenta de linha de comando (`projeto_semana1.sh`) para automatizar a configuração inicial e gerenciar regras de firewall de forma segura e eficiente.

O objetivo é transformar um sistema padrão em uma fortaleza digital, pronta para hospedar aplicações de produção, seguindo as melhores práticas do mercado.

## 2. Estrutura do Repositório

Este diretório contém os artefatos e a documentação gerados durante a Semana 1:

-   `/dia-1-rede`: Anotações sobre a configuração de rede inicial.
-   `/dia-2-ssh`: Backup da configuração de hardening do SSH (`sshd_config_hardened`).
-   `/dia-3-firewall`: Versões iniciais e anotações sobre o script de firewall.
-   `/dia-4-fail2ban`: Backup da configuração local do Fail2Ban (`jail.local`).
-   `/dia-5-selinux`: Guia prático de troubleshooting (`troubleshooting_guide.md`) para SELinux.
-   `projeto_semana1.sh`: A ferramenta CLI final, multifuncional, para hardening e gestão de firewall.

## 3. A Ferramenta: `projeto_semana1.sh`

O artefato principal deste projeto é uma ferramenta de linha de comando em Bash que unifica as tarefas de menu inicial e gerenciamento de firewall.

### 3.1. Arquitetura e Lógica

-   **Modularidade:** O script é organizado em funções (`adicionar_porta`, `remover_porta`, `executar_hardening_inicial`) para clareza e reutilização de código.
-   **Subcomandos:** Utiliza uma estrutura `case` para interpretar subcomandos (`menu`, `add`, `remove`), permitindo uma interface de usuário clara e extensível.
-   **Robustez:** Inclui validações de privilégio (requer `sudo`) и de input do usuário (valida se a porta é um número no intervalo correto).
-   **Feedback:** Fornece saídas coloridas para informar o usuário sobre cada passo, sucesso ou erro.

### 3.2. Manual de Uso

**Comando de Setup Inicial:**
Executa um processo completo de hardening: atualiza o sistema, instala pacotes essenciais (`fail2ban`), configura o firewall para uma porta SSH segura (2222) e habilita o Fail2Ban.
```bash
sudo ./projeto_semana1.sh menu
