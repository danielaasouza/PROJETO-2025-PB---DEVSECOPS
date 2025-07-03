# PROJETO LINUX 2025 PB - DEVSECOPS

Este projeto consiste na configuração de uma instância EC2 na AWS para disponibilzar um servidor Nginx e um script de monitoramento com envio de alertas via Discord. O ambiente foi configurado em uma VPC personalizada com sub-redes públicas e privadas.

---

## Índice

1. [Objetivos](#1-objetivos)  
2. [Tecnologias utilizadas](#2-tecnologias-utilizadas)  
3. [Etapa 1: Configuração do ambiente](#3-etapa-1-configuração-do-ambiente)  
   - [3.1 Criar uma VPC no console AWS](#31-criar-uma-vpc-no-console-aws)  
   - [3.2 Criar uma instância EC2 na AWS](#32-criar-uma-instância-ec2-na-aws)  
   - [3.3 Acessar Instância via SSH](#33-acessar-instância-via-ssh)  
4. [Etapa 2: Configuração do Servidor Web](#4-etapa-2-configuração-do-servidor-web)  
   - [4.1 Instalação do Nginx](#41-instalação-do-nginx)  
   - [4.2 Página HTML](#42-página-html)  
5. [Etapa 3: Monitoramento e Notificações](#5-etapa-3-monitoramento-e-notificações)  
   - [5.1 Criação do Script em bash](#51-criação-do-script-em-bash)  
   - [5.2 Agendamento do Script](#52-agendamento-do-script)  
6. [Etapa 4: Automação e Testes](#6-etapa-4-automação-e-testes)  
   - [6.1 Verifique se o site está funcionando corretamente](#61-verifique-se-o-site-está-funcionando-corretamente)  
   - [6.2 Pare o Nginx para verificar se o Script está emitindo os alertas corretamente](#62-pare-o-nginx-para-verificar-se-o-script-está-emitindo-os-alertas-corretamente)  
   - [6.3 Restaure o serviço](#63-restaure-o-serviço)  
7. [Conclusão](#7-conclusão)  
8. [Referências](#8-referencias)

---

## 1. Objetivos

- Criar uma infraestrutura na AWS com VPC personalizada
- Criar página HTML servida pelo NGINX
- Monitorar disponibilidade através do script em Bash
- Enviar alertas de falha via Discord
- Automatizar o script pelo `crontab`

---

## 2. Tecnologias utilizadas

![Ubuntu](https://img.shields.io/badge/Ubuntu-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)
![Nginx](https://img.shields.io/badge/nginx-%23009639.svg?style=for-the-badge&logo=nginx&logoColor=white)
![Bash Script](https://img.shields.io/badge/bash_script-%23121011.svg?style=for-the-badge&logo=gnu-bash&logoColor=white)
![Discord](https://img.shields.io/badge/Discord-%235865F2.svg?style=for-the-badge&logo=discord&logoColor=white)
![GitHub](https://img.shields.io/badge/github-%23121011.svg?style=for-the-badge&logo=github&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Udemy](https://img.shields.io/badge/Udemy-A435F0?style=for-the-badge&logo=Udemy&logoColor=white)
![HTML5](https://img.shields.io/badge/html5-%23E34F26.svg?style=for-the-badge&logo=html5&logoColor=white)

---

## 3. Etapa 1: Configuração do ambiente

### 3.1 Criar uma VPC no console AWS
1. No Console AWS, acesse **VPC → Suas VPCs → Criar VPC** 

Dentro das Configurações: 
   - Atribua um nome a ela
   - Defina um bloco CIDR: 10.0.0.0/16
   - Número de zonas de disponibilidade (AZs): 2
   - Número de sub-redes públicas: 2
   - Número de sub-redes privadas: 2
   - Gateways NAT (USD): Nenhuma
   - Endpoints da VPC: Gateway do S3
   - Opções de DNS: 
      - [x] Habilitar nomes de host DNS
      - [x] Habilitar resolução de DNS
   - Criar VPC
     
   <img width="773" alt="Captura de Tela 2025 - VPC" src="https://github.com/user-attachments/assets/8b4b45ce-d0d9-40a2-ba08-088bcd0c184f" />

    
2. Após criação da VPC, acesse **VPC → Gateways da Internet → projeto-vpc** para verificar o acesso à internet das sub-redes públicas.

<img width="610" alt="Captura de Tela 2025-07-02 às 14 51 23" src="https://github.com/user-attachments/assets/7bbbeb86-53c6-400c-ab88-66cf1f481cd5" />


  ### 3.2 Criar uma instância EC2 na AWS 
  1. Acesse  **EC2 → Grupos de Segurança → Criar grupo de Segurança**
Nas Configurações:
- Atribua um nome ao grupo de Segurança
- Descrição: Permitir acesso SSH e HTTP à EC2
- VPC: Selecione a vpc criada anteriormente
- Adicione as seguintes regras de entrada:
   
   | Tipo | Protocolo | Intervalo de portas | Origem |
   |------|-----------|---------------------|--------|
   | SSH  |     TCP   |           22        | Qualquer local-IPv4|
   |HTTP  |    TCP    |           80        | Qualquer local-IPv4|
- Criar Grupo de Segurança
2. Acesse **EC2 → Instâncias → Executar uma instância**
- Atribua o nome e tags necessárias para a criação da EC2
- AMI: `Ubuntu Server 24.04`
- Tipo de Instância: `t2.micro`
- Par de chaves: Crie um novo par de chaves .pem e armazene em um local seguro
- Configurações de rede: escolha a vpc criada, uma subnet pública, e por fim selecione o grupo de segurança criado
- Executar Instância
       
<img width="1204" alt="Captura de Tela 2025-07-02 às 15 42 26" src="https://github.com/user-attachments/assets/bd6f2daa-c3a9-43d7-9e32-531a446607ed" />

 ### 3.3 Acessar Instância via SSH
 Para conectar-se via SSH é necessário que a instância esteja em execução, localize o IP público dela, e no terminal digite os seguintes comandos: 
 ```bash
  #para garantir que o SSH permita o uso da chave
   → chmod 400 ~/pasta_da_chave/chave-linux.pem
  #para fazer a conexão
   → ssh -i ~/pasta_da_chave/chave-linux.pem ubuntu@<IP público da instância>
 ```
<img width="520" alt="Captura de Tela 2025-07-02 às 16 20 26" src="https://github.com/user-attachments/assets/0ec1e471-4da7-4e58-bd0c-2e714b2943bf" />

 ---

## 4. Etapa 2: Configuração do Servidor Web
### 4.1 Instalação do Nginx
```bash
# Atualiza a lista de pacotes disponíveis
   → sudo apt update
# Instala o servidor NGINX (-y autoriza sem pedir confirmação)
   → sudo apt install -y nginx
# Inicia o serviço imediatamente
   → sudo systemctl start nginx
   → sudo systemctl enable nginx
# Verifica o status (ativo, inativo, erro...)
   → sudo systemctl status nginx
```

### 4.2 Página HTML
1. Crie uma página HTML personalizada com as informações necessárias
<img width="499" alt="Captura de Tela 2025-07-02 às 19 58 49" src="https://github.com/user-attachments/assets/f3250f51-e727-4459-8613-6e636bcf3f4c" />


```bash
# Dá permissão de dono da pasta /var/www/html para o usuário atual
  → sudo chown -R $USER:$USER /var/www/html
# Abre o editor nano para a criação da página HTML
  → nano /var/www/html/index.html
```
2. Dentro do nano:
```html
!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <title>Projeto Linux 2025</title>
</head>
<body>
  <h1>PROJETO LINUX 2025 PB - DEVSECOPS</h1>
  <p><strong>Objetivo:</strong> Servidor web com monitoramento na AWS</p>
  <p><strong>Serviços utilizados:</strong> Nginx, HTML, Monitoramento via Disco>
  <p><strong>Status:</strong> Online</p>
</body>
</html>
```
3. Verificar o funcionamento da página
- Acesse: http://<IP público da instância>

 <img width="860" alt="Captura de Tela 2025-07-02 às 19 56 42" src="https://github.com/user-attachments/assets/15129729-7ad9-47c9-b92c-2f2be10480ab" />

 ---

 ## 5. Etapa 3: Monitoramento e Notificações
 ### 5.1 Criação do Script em bash
 ```bash
  → sudo nano /usr/local/bin/site.bash
```
 Dentro do nano:
 ```bash
 #!/bin/bash

URL="http://localhost"
LOG="/var/log/monitoramento.log"
DATA=$(date '+%Y-%m-%d %H:%M:%S')

# Testa se o NGINX está respondendo 
if curl -s --head "$URL" | grep "200 OK" > /dev/null; then
  echo "$DATA - OK" >> "$LOG"
else
  echo "$DATA - ERRO" >> "$LOG"

  # Envia alerta no Discord 
  curl -X POST -H "Content-Type: application/json" \
    -d "{\"content\": \"Site fora do ar em $DATA\"}" \
    https://discord.com/api/webhooks/WEBHOOK_DISCORD
fi
```
Control + O → Salvar    |     Control + X  → Sair

No Terminal:
```bash
 # Torna executável
  → sudo chmod +x /usr/local/bin/site.bash
```

### 5.2 Agendamento do Script
```bash
  → sudo crontab -e
```
Escolha o editor nano. Ao abrir, adicione a seguinte linha no arquivo:

```bash
# Faz o Script rodar a cada minuto
 → * * * * * /usr/local/bin/site.bash
```
Salve e feche

---

## 6. Etapa 4: Automação e Testes
### 6.1 Verifique se o site está funcionando corretamente:
 - Acesse o site pelo navegador ou
 - Digite o seguinte comando:
   ```bash
     # Verifica o status do site
     → cat /var/log/monitoramento.log
     ```
<img width="404" alt="Captura de Tela 2025-07-02 às 21 03 56" src="https://github.com/user-attachments/assets/6c99666e-6e17-4efc-8f83-6258571fb0f1" />

OK: O site está no ar | ERRO: Site fora do ar

### 6.2 Pare o Nginx para verificar se o Script está emitindo os alertas corretamente:
   ```bash
     → sudo systemctl stop nginx
   ```
   Após um minuto, verifique o log novamente, deverá aparecer um mensagem de ERRO, e a notificação de alerta do Discord deve disparar.
   
   <img width="378" alt="Captura de Tela 1" src="https://github.com/user-attachments/assets/64924d18-1d55-422f-bb85-09476ad20305" />

<img width="378" alt="Captura de Tela 2" src="https://github.com/user-attachments/assets/847f5a53-5755-4c49-9a5d-b150f4721791" />

### 6.3 Restaure o serviço
   ```bash
    → sudo systemctl start nginx
   ``` 
---

## 7. Conclusão

O projeto proposto foi concluído realizando a criação de uma infraestrutura na AWS, composta por uma VPC personalizada, subnets públicas e privadas, e uma instância EC2 configurada com Nginx. Foi realizado um script para monitoramento em bash, com envio de alertas pelo Discord, e agendado com o cron.

A documentação e os testes retornaram a funcionalidade esperada, com o ambiente  operando corretamente, exibindo a página HTML e notificando falhas conforme o previsto.

Como melhoria futura, destaca-se a possibilidade de utilizar o AWS CloudFormation proposto no desafio bônus para automatizar toda a criação, que vai desde a VPC até a configuração da instância e serviços. Isso traria maior agilidade e segurança ao processo.

---

## 8. Referências

- [Projeto Linux 2025 PB-DEVSECOPS-ABR – Documento oficial (PDF)](https://github.com/SeuUsuario/SeuRepositorio/raw/main/docs/Projeto_Linux_2025.pdf)
- [Guia do usuário do Amazon EC2 para instâncias Linux – AWS](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/)
- [Introdução à VPC (Virtual Private Cloud) – AWS](https://docs.aws.amazon.com/vpc/latest/userguide/)
- [Curso: Primeiros Passos no Linux – Udemy / Compass UOL](https://compassuol.udemy.com/course/primeiros-passos-no-linux/#overview)
