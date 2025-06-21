O SELinux é o chefão de segurança do sistema, manda mais que o root. Ele não tá nem aí pro seu usuário, se é sudo, se a permissão do arquivo é 777...

A única coisa que importa pra ele é: o **crachá do processo** bate com a **etiqueta da sala**?

Se um processo com o crachá `httpd_t` (Nginx) tenta escrever num arquivo com a etiqueta `var_t`, ele barra. Não importa mais nada. É a regra.

**Passos pra quando a coisa quebra:**

**1 - É o SELinux mesmo?**

Primeiro, vejo se ele tá ativo.
`sestatus`

Se tiver `enforcing`, coloco em modo permissivo, que só olha e anota, mas não bloqueia.
`sudo setenforce 0`

Aí testo a aplicação. Funcionou? Pronto. Achei o culpado.

**NÃO ESQUECER** de voltar pro modo seguro depois: `sudo setenforce 1`

**2 - Tá, mas o que ele bloqueou?**

Pra descobrir o porquê, preciso das ferramentas de analise. Se não tiver, instalo:
`sudo dnf install -y setroubleshoot-server policycoreutils-python-utils`

Aí eu rodo o `sealert` pra ele ler o log e me dizer o que aconteceu.
`sudo sealert -a /var/log/audit/audit.log`

Ele geralmente me fala quem foi barrado, onde tentou mexer e às vezes até como consertar.

**3 - Como arrumar a bagunça**

Normalmente são dois passos:

Primeiro, eu defino a etiqueta certa pra pasta/arquivo. Basicamente, avisar pro SELinux que "essa sala aqui pode ser usada por esse processo".
`sudo semanage fcontext -a -t httpd_sys_content_t "/srv/meu-site(/.*)?"`

Depois, eu mando ele aplicar essa etiqueta de verdade.
`sudo restorecon -Rv /srv/meu-site`

Dica pra mim: sempre usar `ls -Z` pra ver se a etiqueta mudou mesmo.

**Lembrete do problema com Nginx:**

Uploads tavam dando erro 403. A pasta de uploads tava com a etiqueta errada (`var_t`). O Nginx precisava de permissão de escrita, então a etiqueta correta era `httpd_sys_rw_content_t`.
Tive que usar `semanage` e `restorecon` pra corrigir.
