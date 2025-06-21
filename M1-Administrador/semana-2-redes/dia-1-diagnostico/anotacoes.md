# Anotações de Diagnóstico de Rede

## Ping em `google.com` vs `8.8.8.8`

Beleza, aqui é o resumo direto:

* Quando eu dou `ping google.com`, o sistema precisa primeiro **descobrir o IP do site** (via DNS). Isso é tipo perguntar “onde fica o Google?” antes de sair andando.

* Já `ping 8.8.8.8` vai direto no alvo, porque já tenho o IP em mãos. Não precisa de DNS, não precisa perguntar nada pra ninguém.

Resumo da ópera:

* Se `ping google.com` falha, pode ser problema de **DNS**.
* Se `ping 8.8.8.8` falha, aí o problema é **rede mesmo** (sem internet ou rota quebrada).

Ah, e outro detalhe:

* `google.com` pode resolver pra vários IPs diferentes (balanceamento de carga).
* `8.8.8.8` é sempre o mesmo — um servidor DNS do próprio Google.

## O que o `traceroute` me mostra?

O `traceroute` é tipo um detetive: ele me mostra **por onde os pacotes estão passando** até chegar no destino.

Ele faz isso pulando de roteador em roteador (os tais "hops") e dizendo:

* "Passei por aqui (IP tal), demorou X ms"

Por exemplo:

```
1  roteador da sua casa
2  roteador do provedor
...
10 destino final
```

Pra cada hop ele mostra 3 tempos de resposta. Se tiver `* * *`, é porque aquele salto não respondeu (pode estar bloqueando ICMP ou com delay).

**TTL** entra na jogada aqui: o traceroute manda pacotes com TTL começando em 1, depois 2, depois 3... Cada roteador vai "comendo" 1 do TTL e quando ele zera, o roteador avisa de volta. É assim que o caminho vai sendo revelado.

## Quando usar cada um:

* `ping 8.8.8.8`: testando se tem internet básica (sem DNS).
* `ping google.com`: testando DNS + internet.
* `traceroute`: pra ver onde tá o gargalo, ou onde o pacote tá morrendo no caminho.

---

Dica final:

> Se `ping` falha mas `traceroute` mostra os primeiros hops, provavelmente o problema tá mais perto do destino.

> Se nenhum dos dois responde, o problema tá na sua rede mesmo.
