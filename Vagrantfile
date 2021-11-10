# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "debian/buster64"
  config.vm.box_check_update = false

  #Main vm
  config.vm.define 'main' do |main|
    main.vm.hostname = 'main'
    main.vm.network 'private_network', ip: '192.168.50.10'
    main.vm.provider 'virtualbox' do |m|
      m.customize ["modifyvm", :id, "--natdnshostresolver1", "on" ]
      m.customize ["modifyvm", :id, "--memory", 2048]
      m.customize ["modifyvm", :id, "--name", "main"]
      m.customize ["modifyvm", :id, '--cpus', "2"]
    end
    main.vm.provision "shell", path: "provision.sh"
  end



  #Give the access to ssh connect
  config.vm.provision "shell", inline: <<-SHELL
  sed -i 's/ChallengeResponseAuthentication no/ChallengeResponseAuthentication yes/g' /etc/ssh/sshd_config
  service ssh restart
  SHELL

end
