
## Brincando com o CoreOS...
# CoreOS Kids Vagrant
Exemplo de um Vagrantfile subindo varias **VM CoreOS** sobre uma **configuração simples**.

O CoreOS é um sistema operacional Linux desenvolvido para ser tolerante à falhas, 
distribuído e fácil de escalar. Ele tem sido utilizado por times de operações e 
ambientes alinhados com a cultura DevOps.

A principal diferença do CoreOS para outras distribuições Linux minimalistas é o 
fato de ser desenvolvido para suportar nativamente o funcionamento em cluster, 
possuir poucos binários e não possuir um sistema de empacotamento (como apt-get 
ou yum). O sistema operacional consite apenas no Kernel e no systemd. Ele depende 
de containers para gerenciar a instalação de software e aplicações no sistema 
operacional, provendo um alto nível de abstração. Desta forma, um serviço e todas 
as suas dependências são empacotadas em um container e podem ser executadas em uma 
ou diversas máquinas com o CoreOS, **Como descrito neste post:** 
***"[CoreOS: O que é e como funciona?](https://www.ricardomartins.com.br/2015/05/05/coreos-o-que-e-e-como-funciona/)"*** 
por **Ricardo Martins**.

> **Nota:**
> *Esse projeto se basease no projeto 
  "[multiple-nodes-vagrant](https://github.com/alisonbuss/multiple-nodes-vagrant/)" e no 
  "[coreos-vagrant](https://github.com/coreos/coreos-vagrant/)", mas informamações 
  do projeto coreos-vagrant no site oficial [aqui!](https://coreos.com/os/docs/latest/booting-on-vagrant.html).* 
>  

## Começando:

1) Instalar dependências

* [VirtualBox](https://www.virtualbox.org/) 4.3.10 ou superior..
* [Vagrant](https://www.vagrantup.com/downloads.html) 1.6.3 ou superior.

2) Clone este projeto para começá-lo a funcionar!

```
$ git clone https://github.com/alisonbuss/coreos-kids-vagrant/
$ ls coreos-kids-vagrant
...
 coreos-kids-vagrant
  |---cloud-config/cloud-config.yaml 'Pasta contendo arquivo de configuração init do CoreOS'
  |---log/                           'Pasta de arquivos de log'
  |---shared-folder/                 'Pasta de compartilhamento da máquina para VM'
  |---shared-folder/docker/          'Pasta de compartilhamento da máquina para VM'
  |---shared-folder/text.txt         'Arquivo a ser compartilhado'
  |---instances.config.rb            'ARQUIVO PRINCIPAL!! onde configura as VM CoreOS'
  |---LICENSE                        'Licença Pública Geral GNU v3.0'  
  |---README.md                      'Instruções de uso'
  |---Vagrantfile                    'Arquivo vagrant'
...
$ cd coreos-kids-vagrant
```

3) Inicialização e SSH

    O provedor usando é o **VirtualBox** e é o provedor padrão do Vagrant.

```
$ vagrant up
RUN: automatically replace the discovery token on 'vagrant up'
==> generate a new discovery token for cluster, example: 'https://discovery.etcd.io/new?size=3'
==> token: https://discovery.etcd.io/291e3da335bb0b0774a0b388cac1b836
Bringing machine 'coreos01.example.com' up with 'virtualbox' provider...
Bringing machine 'coreos02.example.com' up with 'virtualbox' provider...
Bringing machine 'coreos03.example.com' up with 'virtualbox' provider...
...

$ vagrant ssh coreos01.example.com
...

core@coreos01 ~ $ sudo etcdctl cluster-health
member 3eecb18b204156fa is healthy: got healthy result from http://172.17.8.103:2379
member 416d18e57fb1686c is healthy: got healthy result from http://172.17.8.101:2379
member a05b4a3b54c19024 is healthy: got healthy result from http://172.17.8.102:2379
cluster is healthy
...

core@coreos01 ~ $ sudo fleetctl list-machines
MACHINE		IP		METADATA
437c131b...	172.17.8.103	-
650459b2...	172.17.8.102	-
8e9c2312...	172.17.8.101	-
...

core@coreos01 ~ $ exit
...

$ vagrant ssh coreos02.example.com
...
core@coreos02 ~ $ exit
...

$ vagrant ssh coreos03.example.com
...
core@coreos03 ~ $ exit
...

```

### **Arquivo Principal** *de configuração para subir instancias CoreOS*:

```
$ cat instances.config.rb

=begin ############################################################################

Official Box: (coreos-stable, coreos-beta, coreos-alpha)   

Official Box Urls from current versions: 
   Stable --> https://storage.googleapis.com/stable.release.core-os.net/amd64-usr/current/coreos_production_vagrant.json
   Beta ----> https://storage.googleapis.com/beta.release.core-os.net/amd64-usr/current/coreos_production_vagrant.json
   Alpha ---> https://storage.googleapis.com/alpha.release.core-os.net/amd64-usr/current/coreos_production_vagrant.json
   
Instance default values:    

    INSTANCES = {                                                                                                                   
        :"name-instance" => {                                                                                                     
            box: "coreos-alpha",                                                                                                  
            boxVersion: "current",                                                                                                
            updateChannel: "alpha",                                                                                                  
            boxURL: "https://storage.googleapis.com/alpha.release.core-os.net/amd64-usr/current/coreos_production_vagrant.json",  
            cpus: 1,                                                                                                               
            memory: 512,                                                                                                          
            enableLogging: false,                                                                                                 
            enableSharedFolders: false,                                                                                           
            overrideSharedFolders: [],                                                                                            
            network: [                                                                                                             
                { type: "private_network", settings: { ip: "172.17.8.101..." }}                                                   
            ],                                                                                                                    
            provision: [
                { type: "file", settings: { source: "#{SPECIFY_CLOUD_CONFIG_PATH}", destination: "/tmp/vagrantfile-user-data" }},
                { type: "shell", settings: { inline: "mv /tmp/vagrantfile-user-data /var/lib/coreos-vagrant/", privileged: true }}
            ]
        }, ...
    }

Example a cluster with 3 nodes:

    INSTANCES = {
        :"coreos01" => { enableSharedFolders: true },
        :"coreos02" => { enableSharedFolders: true },
        :"coreos03" => { enableSharedFolders: true }
    }  
    
=end ##############################################################################

DOMAIN = "example.com"

SPECIFY_CLOUD_CONFIG_PATH = "cloud-config/cloud-config.yaml"

INSTANCES = {
    :"core01" => {
        enableSharedFolders: true,
        overrideSharedFolders: [
            {host: "shared-folder/", guest: "/home/core/shared-folder", settings:{ 
                id: "shared-override-01", nfs: true, mount_options: ['nolock,vers=3,udp'] 
            }}
        ],
        network: [
            { type: "private_network", settings: { ip: "172.17.8.101" }}
        ],
    },
    :"core02" => {
        enableSharedFolders: true,
        network: [
            { type: "private_network", settings: { ip: "172.17.8.102" }}
        ],
    }
}

GLOBAL_SHARED_FOLDERS = [
    {host: "shared-folder/", guest: "/home/core/shared"},
    {host: "shared-folder/docker", guest: "/home/core/shared-docker", settings:{ create: true }}
]
```

### **Usando Cloud-Config**:

CoreOS permite-lhe declarativamente personalizar vários itens de nível de SO, 
tais como configuração de rede, contas de utilizador e unidades systemd. Este 
documento descreve a lista completa de itens que podemos configurar. O 
coreos-cloudinitprograma usa esses arquivos como ele configura o sistema 
operacional após a inicialização ou durante o tempo de execução.

Seu cloud-config é processado durante cada inicialização. 

**Documentação do [Cloud-Config](https://coreos.com/os/docs/1353.1.0/cloud-config.html)**

```
$ cat cloud-config/cloud-config.yaml

#cloud-config

coreos:
  etcd2:
    # generate a new discovery token for each unique cluster of size equals (2), example: "https://discovery.etcd.io/new?size=2"
    discovery: https://discovery.etcd.io/47eefb9c58ea292f3ad69673ea21f28e
    # multi-region and multi-cloud deployments need to use $public_ipv4
    advertise-client-urls: http://$public_ipv4:2379
    initial-advertise-peer-urls: http://$private_ipv4:2380
    # listen on both the official ports and the legacy ports
    # legacy ports can be omitted if your application doesn't depend on them
    listen-client-urls: http://0.0.0.0:2379,http://0.0.0.0:4001
    listen-peer-urls: http://$private_ipv4:2380,http://$private_ipv4:7001 
  fleet:
    public-ip: $public_ipv4
  flannel:
    interface: $public_ipv4
  units:
    - name: etcd2.service
      command: start
    - name: fleet.service
      command: start
    - name: flanneld.service
      drop-ins:
      - name: 50-network-config.conf
        content: |
          [Service]
          ExecStartPre=/usr/bin/etcdctl set /coreos.com/network/config '{ "Network": "10.1.0.0/16" }'
      command: start
    - name: docker-tcp.socket
      command: start
      enable: true
      content: |
        [Unit]
        Description=Docker Socket for the API

        [Socket]
        ListenStream=2375
        Service=docker.service
        BindIPv6Only=both

        [Install]
        WantedBy=sockets.target
```