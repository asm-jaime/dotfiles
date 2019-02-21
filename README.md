### dotfiles

 Here are my personal environment. I'm use:
  * vm: vmware, docker
  * system: ubuntu
  * installer: ansible
  * shell: bash
  * editor: nvim
  * browser: chrome
  * file manager: doublecmd
  * for edit source files: golang/c/javascript

#### how it looks

![Image of tmux panel](docs/example.vi.png)

Another examples in here [/docs](./docs)

#### Folders

  * `conf.ansible` - instructions/scripts/files for configure/install environment
  * `conf.bash` - dotfiles for std.shell
  * `conf.util` - dotfiles for all other utilites, like eslint/youcompleteme/..
  * `docs`- docs/faqs/examples

#### Preparation

  * `cd ~`
  * `sudo apt-get install git`
  * `git clone https://github.com/asm-jaime/dotfiles`
  * `bash ~/dotfiles/conf.ansible/start.install.ansible.sh`
  * `sudo apt install gcc && sudo apt install build-essential && sudo apt-get update && sudo apt install net-tools`
  
#### vmwtools (the only when under vmware environment)
  * `put the linux.iso from host system to virtual cdrom, or click 'menu->Install VMware Tools...'`
  * `copy VMWareTools*.gz to /tmp and cd /tmp/vmware-tools`
  * `sudo ./vmware-install.pl`
    * if the warning: 'the path is not valid path to the gcc binary', press 'y'->'/usr/bin/gcc'->'n'
    * if the warning: 'Would you like to enable VMware automatic kernel modules?', press 'y'

#### Individual/sequence of installation (ansible and sudo password required):
  * `cd ~/.vim/conf.ansible`
  * `ansible-playbook play.chrome.yml`
  * `ansible-playbook play.doublecmd.yml`
  * `ansible-playbook play.git.yml` (quick configure your git. `~/.ssh` keys required)
  * `ansible-playbook play.node.yml`
  * `ansible-playbook play.docker.yml` (logout required)
  * `ansible-playbook play.mongodb.yml`
  * `ansible-playbook play.vi.yml`
