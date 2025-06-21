# Guia de Soluçag para SELinux

Este guia serve como um passo a passo para diagnosticar e resolver problemas causados pelas políticas de segurança do SELinux, especialmente em servidores web como Nginx ou Apache.

## O Checklist de Sanidade Mental

Antes de qualquer coisa, responda a estas perguntas para um diagnóstico rápido:

- [ ] **O SELinux está ativo?** Verifique com `sestatus`.
- [ ] **O problema some com `setenforce 0`?** Se sim, o culpado foi encontrado.
- [ ] **O log de auditoria registrou o bloqueio?** Use `sealert` para investigar.
- [ ] **A etiqueta (contexto) do arquivo/pasta está correta?** Verifique com `ls -Z`.
- [ ] **A nova política foi definida?** Foi usado o `semanage fcontext`?
- [ ] **A nova política foi aplicada?** Foi usado o `restorecon`?
- [ ] **O modo `enforcing` foi reativado?** Lembre-se de rodar `setenforce 1`.


## Passo a Passo para a Solução

### Etapa 1: Confirmar a Causa Raiz

O primeiro passo é isolar o problema. Vamos verificar se o SELinux está ativo e, em seguida, desativar temporariamente seu bloqueio para confirmar se ele é a causa.

**1. Verifique o Status:**
sestatus

Se o `Current mode` for `enforcing`, ele está ativamente aplicando as políticas.

**2. Mude para o Modo Permissivo:**
Este comando faz com que o SELinux registre as violações de política, mas não as bloqueie.

sudo setenforce 0

Teste sua aplicação novamente. Se tudo funcionar, você tem 100% de certeza que o problema é uma política do SELinux.


**3. Retorne à Segurança:**
É **crucial** reativar o modo de bloqueio após o teste para não deixar o sistema vulnerável.

sudo setenforce 1


### Etapa 2: Investigar o Bloqueio

Agora que sabemos que o SELinux é o responsável, precisamos entender *o que* exatamente ele bloqueou. A ferramenta `sealert` é perfeita para isso.

**1. Instale as Ferramentas (se necessário):**

sudo dnf install -y setroubleshoot-server policycoreutils-python-utils

**2. Analise os Logs:**
O `sealert` traduz os logs de auditoria complexos em um relatório legível, geralmente com sugestões de correção.

sudo sealert -a /var/log/audit/audit.log

Preste atenção no `Source Process` e no `Target File` para entender a interação que foi bloqueada.


### Etapa 3: Aplicar a Correção Permanente

A correção mais comum é ajustar o contexto de segurança (a "etiqueta") de um arquivo ou diretório para que o SELinux o considere seguro para um determinado processo.

**1. Defina o Contexto Correto:**
O comando `semanage fcontext` cria uma regra permanente para o SELinux. O exemplo abaixo define que o diretório `/srv/meu-site` e tudo dentro dele deve ter o contexto `httpd_sys_content_t`, que é legível pelo servidor web.

```bash
# Sintaxe: semanage fcontext -a -t TIPO_DE_CONTEXTO "/caminho/do/arquivo_ou_pasta(/.*)?"
sudo semanage fcontext -a -t httpd_sys_content_t "/srv/meu-site(/.*)?"

**2. Aplique o Contexto no Sistema de Arquivos:**
O comando `restorecon` lê as regras definidas e as aplica efetivamente nos arquivos e diretórios.

# O -R é para recursividade e o -v para modo "verbose" (mostrar o que está fazendo)
sudo restorecon -Rv /srv/meu-site


## Exemplo Prático: Uploads com Erro 403 no Nginx

* **Problema:** Uma aplicação web não conseguia salvar arquivos enviados em `/srv/uploads`.
* **Diagnóstico:** O `sealert` mostrou que o processo `httpd_t` (Nginx) foi impedido de escrever (`write`) no diretório `/srv/uploads` porque este tinha o contexto `default_t`.
* **Solução:** Alterar o contexto do diretório para `httpd_sys_rw_content_t`, que permite ao servidor web ler e escrever.

    sudo semanage fcontext -a -t httpd_sys_rw_content_t "/srv/uploads(/.*)?"
    sudo restorecon -Rv /srv/uploads

## Lições e Dúvidas

* **Coisas que aprendi:** Nem tudo é `chmod`/`chown`. O `sealert` é seu amigo. Nunca deixe o servidor em modo `permissive` por preguiça.
