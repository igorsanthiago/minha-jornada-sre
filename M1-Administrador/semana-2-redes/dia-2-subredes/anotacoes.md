# Dia 2 – Endereço e Sub-redes

**IP detectado:** `192.168.1.105/24`

---

## 1. Endereço de Rede  
- **Cálculo:** mantenho os 3 primeiros octetos do IP e zer o quarto  
- **Resultado:** `192.168.1.0`  
- **Significado:** identifica o bloco de rede inteiro; não pode ser atribuído a hosts.

## 2. Endereço de Broadcast  
- **Cálculo:** mantenho os 3 primeiros octetos e ponho 255 no quarto  
- **Resultado:** `192.168.1.255`  
- **Significado:** endereço que, quando usado como destino, envia pacotes para **todos** os hosts da sub-rede.

## 3. Faixa de Hosts Utilizáveis  
- **Primeiro host:** `192.168.1.1`  
- **Último host:**  `192.168.1.254`  
- **Significado:** endereços que podem ser atribuídos a dispositivos; excluem o .0 (rede) e o .255 (broadcast).

---

## 4. Explicação com minhas palavras

- **Endereço de Rede:**  
  É o “rótulo” que identifica toda a sub-rede. Em `/24`, fixamos os 24 bits iniciais (três octetos) e zeramos os 8 bits finais.  

- **Endereço de Broadcast:**  
  É o endereço especial que atinge **todos** os hosts da rede; colocamos 255 nos bits de host para “gritar” na sub-rede.  

- **Faixa de Hosts:**  
  São os endereços que podem ser atribuídos a dispositivos individuais. Já que 0 é reservado para a rede e 255 para broadcast, os hosts válidos ficam de .1 a .254.  


