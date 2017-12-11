# -*- mode: ruby -*-
# # vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"
PROJECT_PATH = File.dirname(__FILE__)

puts ""
puts "PATH PROJECT: '#{PROJECT_PATH}'"
puts ""

require "#{PROJECT_PATH}/instances.config.rb"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

    # plugin conflict
    if Vagrant.has_plugin?("vagrant-vbguest") then
        config.vbguest.auto_update = false
    end

    # automatically replace the discovery token on 'vagrant up'
    if File.exists?(SPECIFY_CLOUD_CONFIG_PATH) && ARGV[0].eql?('up')
        require "yaml"
        require "open-uri"
        token = open("https://discovery.etcd.io/new?size=#{INSTANCES.length}").read
        puts "RUN: automatically replace the discovery token on 'vagrant up'"
        puts "==> generate a new discovery token for cluster, example: 'https://discovery.etcd.io/new?size=#{INSTANCES.length}'"
        puts "==> token: #{token}"
        data = YAML.load(IO.readlines(SPECIFY_CLOUD_CONFIG_PATH)[1..-1].join)
        if data.key? 'coreos' and data['coreos'].key? 'etcd2'
            data['coreos']['etcd2']['discovery'] = token
        end
        yaml = YAML.dump(data)
        File.open(SPECIFY_CLOUD_CONFIG_PATH, 'w') { |file| file.write("#cloud-config\n\n#{yaml}") }
    end

    (INSTANCES).each_with_index do |(nameInstance, settings), index| 
        # define default values
        _nameInstance = nameInstance
        _hostname = (DOMAIN.empty? ? _nameInstance : "#{_nameInstance}.#{DOMAIN}") 
        
        _boxVersion = ((settings.key?(:boxVersion) && !settings[:boxVersion].empty?) ? settings[:boxVersion] : "current")  
        _updateChannel = ((settings.key?(:updateChannel) && !settings[:updateChannel].empty?) ? settings[:updateChannel] : "alpha") 
        _box = ((settings.key?(:box) && !settings[:box].empty?) ? settings[:box] : "coreos-#{_updateChannel}") 
        _urlOfficialCoreOS = "https://storage.googleapis.com/#{_updateChannel}.release.core-os.net/amd64-usr/#{_boxVersion}/coreos_production_vagrant.json" 
        _boxURL = ((settings.key?(:boxURL) && !settings[:boxURL].empty?) ? settings[:boxURL] : _urlOfficialCoreOS)    

        _cpus = (settings.key?(:cpus) ? settings[:cpus] : 1)
        _memory = (settings.key?(:memory) ? settings[:memory] : 512)
        _enableLogging = (settings.key?(:enableLogging) ? settings[:enableLogging] : false)
        _enableSharedFolders = (settings.key?(:enableSharedFolders) ? settings[:enableSharedFolders] : false)

        _overrideSharedFolders = (settings.key?(:overrideSharedFolders) && !settings[:overrideSharedFolders].empty? ? settings[:overrideSharedFolders] : nil)
        _network = (settings.key?(:network) ? settings[:network] : [
            { type: "private_network", settings: { ip: "172.17.8.#{100+index+1}" }}
        ])
        _provision = (settings.key?(:provision) ? settings[:provision] : [
            { type: "file", settings: { source: "#{SPECIFY_CLOUD_CONFIG_PATH}", destination: "/tmp/vagrantfile-user-data" }},
            { type: "shell", settings: { inline: "mv /tmp/vagrantfile-user-data /var/lib/coreos-vagrant/", privileged: true }}
        ])

        config.vm.define _hostname do |config|
            # define access --------------------------------------------------------------
            config.vm.hostname = _hostname
            config.ssh.insert_key = false
            config.ssh.forward_agent = true        
            # define box -----------------------------------------------------------------
            if _box.nil? == false then 
                config.vm.box = _box
            end
            if _boxURL.nil? == false then
                config.vm.box_url = _boxURL
            end
            if (_boxVersion.nil? == false) && (!_boxVersion.empty?) && (_boxVersion != "current") then
                config.vm.box_version = _boxVersion
            end
            # provider virtualbox --------------------------------------------------------
            config.vm.provider "virtualbox" do |vb|
                vb.gui = false
                vb.cpus = _cpus
                vb.memory = _memory
                vb.functional_vboxsf = false
                vb.check_guest_additions = false
                vb.customize ["modifyvm", :id, "--cpuexecutioncap", "100"]
            end
            # provider network -----------------------------------------------------------
            if _network.nil? == false then
                (_network).each do |(item)|
                    config.vm.network "#{item[:type]}", item[:settings]
                end
            end 
            # provider VM ----------------------------------------------------------------
            if _provision.nil? == false then
                (_provision).each do |(item)|
                    config.vm.provision "#{item[:type]}", item[:settings]
                end
            end 
            # provider shared folders ----------------------------------------------------
            if _enableSharedFolders == true then
                if _overrideSharedFolders.nil? == false then
                    (_overrideSharedFolders).each do |(item)|
                        config.vm.synced_folder item[:host], item[:guest], (item.key?(:settings) ? item[:settings] : {})
                    end
                else 
                    (GLOBAL_SHARED_FOLDERS).each do |(item)|
                        config.vm.synced_folder item[:host], item[:guest], (item.key?(:settings) ? item[:settings] : {})
                    end 
                end 
            end 
            # generates log --------------------------------------------------------------
            if _enableLogging == true then
                logdir = File.join("#{PROJECT_PATH}", "log")
                FileUtils.mkdir_p(logdir)
                serialFile = File.join(logdir, "#{_nameInstance}-serial.txt")
                FileUtils.touch(serialFile)

                config.vm.provider :virtualbox do |vb, override|
                    vb.customize ["modifyvm", :id, "--uart1", "0x3F8", "4"]
                    vb.customize ["modifyvm", :id, "--uartmode1", serialFile]
                end
            end
        end
       
    end
end