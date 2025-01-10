#!/bin/bash

# Atualizar pacotes do sistema
echo "Atualizando pacotes do sistema..."
apt update && apt upgrade -y

# Instalar pacotes necessários para virtualização e QEMU
echo "Instalando pacotes para virtualização..."
apt install -y qemu qemu-kvm libvirt-bin virt-manager bridge-utils cpu-checker

# Verificar se o KVM está funcionando
echo "Verificando se o KVM está funcionando..."
kvm-ok

# Instalar drivers da GPU (adaptar conforme sua GPU)
echo "Instalando drivers para GPU..."
# Para GPU NVIDIA
apt install -y nvidia-driver nvidia-cuda-toolkit

# Verificar se a GPU está sendo reconhecida
nvidia-smi

# Criar a máquina virtual (ajuste os parâmetros conforme necessário)
echo "Criando a máquina virtual..."
qemu-system-x86_64 \
    -enable-kvm \
    -m 16G \
    -cpu host \
    -smp 4 \
    -vga none \
    -display none \
    -drive file=/var/lib/libvirt/images/vps_image.qcow2,format=qcow2 \
    -netdev user,id=network0,hostfwd=tcp::2222-:22 \
    -device virtio-net,netdev=network0 \
    -device vfio-pci,host=00:02.0 \  # Use a ID da sua GPU
    -cdrom /path/to/your/ubuntu.iso

# Adicionar a chave SSH à VM (se necessário)
echo "Adicionando a chave SSH à VM..."
mkdir -p ~/.ssh
echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEArxD1iWmLjds3fOXXV7l0fvCq9D9vGeLhf7U0ayF2g5eKXjCm7c4M5hfy5P/kt5tzF0cId3BlXjV9nm7Uy36jbLOl+huImIYJ0+RmWqicGHWbZmA== user@hostname" >> ~/.ssh/authorized_keys

# Criar o arquivo de imagem da VM (se necessário)
echo "Criando imagem para a máquina virtual..."
qemu-img create -f qcow2 /var/lib/libvirt/images/vps_image.qcow2 30G

# Iniciar a máquina virtual
echo "Iniciando a máquina virtual..."
virt-install --name vps1 --ram 16384 --vcpus 4 --disk path=/var/lib/libvirt/images/vps_image.qcow2,bus=virtio,format=qcow2 \
  --network network=default --graphics vnc,listen=0.0.0.0 --os-type linux --os-variant ubuntu20.04 --cdrom /path/to/ubuntu.iso

# Configurar a rede para acessar a VM (se necessário)
echo "Configurando rede para a máquina virtual..."
virsh net-start default
virsh net-autostart default

# Finalizar configuração
echo "Configuração de VPS concluída!"
