
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
    :"coreos01" => { enableSharedFolders: true },
    :"coreos02" => { enableSharedFolders: true },
    :"coreos03" => { enableSharedFolders: true }
} 

GLOBAL_SHARED_FOLDERS = [
    {host: "shared-folder/", guest: "/home/core/shared"},
    {host: "shared-folder/docker", guest: "/home/core/shared-docker", settings:{ create: true }}
]