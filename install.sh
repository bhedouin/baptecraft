#!/bin/bash
# wget -qO install.sh https://baptecraft.ovh/install && bash install.sh
echo "
╔╗────────╔╗────────────╔═╗╔╗
║║───────╔╝╚╗───────────║╔╬╝╚╗
║╚═╦══╦══╬╗╔╬══╦══╦═╦══╦╝╚╬╗╔╝
║╔╗║╔╗║╔╗║║║║║═╣╔═╣╔╣╔╗╠╗╔╝║║
║╚╝║╔╗║╚╝║║╚╣║═╣╚═╣║║╔╗║║║─║╚╗
╚══╩╝╚╣╔═╝╚═╩══╩══╩╝╚╝╚╝╚╝─╚═╝
──────║║
──────╚╝
— Voici l'installateur de baptecraft —
IP de la passerelle réseau : $(tput setaf 3)$(route -n | awk '$4 == "UG" {print $2}')$(tput sgr 0)
IP de l'hôte : $(tput setaf 3)$(hostname -I | awk '{print $1}')$(tput sgr 0)
IP publique de l'hôte : $(tput setaf 3)$(curl -s https://checkip.hedouin.eu/ || curl -s https://checkip.amazonaws.com/)$(tput sgr 0)
Nom de code de la version : $(tput setaf 3)$(lsb_release -sc)$(tput sgr 0)
"
if [[ $(id -u) -ne 0 ]] ; then echo "Veuillez exécuter en tant qu'utilisateur root" ; exit 1 ; fi
read -r -p "L'installation est sur le point de commencer, voulez-vous continuer ? (cela peut prendre un certain temps)... [O/n] " response
case "$response" in
    [oO][eE][sS]|[oO])
        ;;
    *)
        exit 0
        ;;
esac
case "$(curl -s --max-time 2 -I https://www.google.fr/ | sed 's/^[^ ]*  *\([0-9]\).*/\1/; 1q')" in
  [23]) echo "\n[$(tput setaf 2)✓$(tput sgr 0)] L'accès à l'internet fonctionne\n";;
  5) echo "\n[$(tput setaf 1)X$(tput sgr 0)] Le proxy web ne nous laisse pas passer\n";;
  *) echo "\n[$(tput setaf 1)X$(tput sgr 0)] Le réseau est en panne ou très lent\n";;
esac
sed -i 's/deb.debian.org/debian.proxad.net/' /etc/apt/sources.list
apt update && apt -y full-upgrade && apt install -y curl git megatools nmap openjdk-17-jdk python3-pip screen ufw unattended-upgrades unzip webp && pip3 install -q gdown dynmap_timemachine pwncat-cs yt-dlp
read -r -p "Voulez-vous installer Cloudflare Dynamic DNS IP Updater ? [O/n] " response
case "$response" in
    [oO][eE][sS]|[oO]) 
        cd || exit
        wget -qO cloudflare.sh https://raw.githubusercontent.com/K0p1-Git/cloudflare-ddns-updater/main/cloudflare-template.sh
        chmod +x cloudflare.sh
        sed -i 's/auth_email=.*/auth_email="baptiste@hedouin.eu"/' cloudflare.sh
        sed -i 's/auth_key=.*/auth_key="Lx8c-k69oRRD1RIQbdeb_Dh7QNk69YPxkLqLL0Qk"/' cloudflare.sh
        sed -i 's/zone_identifier=.*/zone_identifier="840e558afd704b7ac3371a359e456e7e"/' cloudflare.sh
        mkdir /root/.cf-ddns && cd /root/.cf-ddns || exit
        cp /root/cloudflare.sh /root/.cf-ddns/cf-map.sh
        cp /root/cloudflare.sh /root/.cf-ddns/cf-play.sh
        cp /root/cloudflare.sh /root/.cf-ddns/cf-analytics.sh
        sed -i 's/record_name=.*/record_name="map.baptecraft.ovh"/' /root/.cf-ddns/cf-map.sh
        sed -i 's/record_name=.*/record_name="play.baptecraft.ovh"/' /root/.cf-ddns/cf-play.sh
        sed -i 's/record_name=.*/record_name="analytics.baptecraft.ovh"/' /root/.cf-ddns/cf-analytics.sh
        echo "*/1 * * * * /bin/bash bash /root/.cf-ddns/cf-map.sh" > /root/cloudflare
        echo "*/1 * * * * /bin/bash bash /root/.cf-ddns/cf-play.sh" >> /root/cloudflare
        echo "*/1 * * * * /bin/bash bash /root/.cf-ddns/cf-analytics.sh" >> /root/cloudflare
        crontab cloudflare
        rm /root/cloudflare.sh /root/cloudflare
        printf "\n[$(tput setaf 2)✓$(tput sgr 0)] Installation réussie de Cloudflare Dynamic DNS IP Updater\n"
        ;;
esac
read -r -p "Voulez-vous installer OpenVPN ? [O/n] " response
case "$response" in
    [oO][eE][sS]|[oO]) 
        cd || exit
        wget -q https://raw.githubusercontent.com/Nyr/openvpn-install/master/openvpn-install.sh
        chmod +x openvpn-install.sh
        bash openvpn-install.sh
        printf "\n[$(tput setaf 2)✓$(tput sgr 0)] Installation réussie de OpenVPN\n"
        ;;
esac
read -r -p "Voulez-vous installer CrowdSec ? [O/n] " response
case "$response" in
    [oO][eE][sS]|[oO]) 
        curl -sSL https://packagecloud.io/install/repositories/crowdsec/crowdsec/script.deb.sh | bash
        apt install -y crowdsec
        printf "\n[$(tput setaf 2)✓$(tput sgr 0)] Installation réussie de CrowdSec\n"
        ;;
esac
read -r -p "Voulez-vous installer Docker ? [O/n] " response
case "$response" in
    [oO][eE][sS]|[oO]) 
        curl -sSL https://get.docker.com | bash
        apt install -y containerd.io docker-ce-cli
        printf "\n[$(tput setaf 2)✓$(tput sgr 0)] Installation réussie de Docker\n"
        ;;
esac
read -r -p "Voulez-vous installer Impostor ? [O/n] " response
case "$response" in
    [oO][eE][sS]|[oO]) 
        docker run -d --restart=always -p 22023:22023/udp -e PUID=$(id -u) -e PGID=$(id -u) aeonlucid/impostor:latest
        printf "\n[$(tput setaf 2)✓$(tput sgr 0)] Installation réussie de Impostor\n"
        ufw allow 22023 2> /dev/null
        printf "— $(tput setaf 3)https://baptecraft.ovh/baptus/\n$(tput sgr 0)"
        ;;
esac
read -r -p "Voulez-vous installer Minecraft ? [O/n] " response
case "$response" in
    [oO][eE][sS]|[oO]) 
        mkdir /home/minecraft && cd /home/minecraft || exit
        wget -q https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar https://gist.githubusercontent.com/baptiste313/32237df60b8ae0e018eacc741f0175e2/raw/d19efbf9f1606a746d64d25acb8d4242b646267a/start.sh
        gdown -g https://drive.google.com/file/d/1EPJiNZqa0whfJrJOrMz3_QiL-MxWMDFm/view?usp=sharing
        unzip -qq baptecraft.zip
        mv /home/minecraft/baptecraft/* /home/minecraft
        sed -i "s/network-compression-threshold=256/network-compression-threshold=512/g" server.properties
        sed -i "s/spawn-protection=16/spawn-protection=0/g" server.properties
        sed -i "s/snooper-enabled=true/snooper-enabled=false/g" server.properties
        sed -i "s/max-tick-time=60000/max-tick-time=120000/g" server.properties
        java -Xmx1024M -jar /home/minecraft/BuildTools.jar --rev 1.18
        java -Xms512M -Xmx1024M -jar /home/minecraft/spigot-1.18.jar nogui
        sed -i 's/false/true/g' /home/minecraft/eula.txt
        rm -rf /home/minecraft/baptecraft
        chmod +x start.sh
        cp start.sh /home/pi
        cp start.sh /root
        wget -qP plugins/ https://dynmap.us/builds/dynmap/Dynmap-3.3-SNAPSHOT-spigot.jar https://download.discordsrv.com/snapshot https://github.com/plan-player-analytics/Plan/releases/download/5.4.1516/Plan-5.4-build-1516.jar https://cdn.discordapp.com/attachments/804019242512810034/916652709267009606/TreeAssist.jar https://github.com/griefergames/PlugMan/releases/download/3.0.0/PlugMan.jar https://media.forgecdn.net/files/3462/546/Multiverse-Core-4.3.1.jar https://ci.opencollab.dev/job/GeyserMC/job/Geyser/job/master/lastSuccessfulBuild/artifact/bootstrap/spigot/target/Geyser-Spigot.jar https://ci.extendedclip.com/job/PlaceholderAPI/lastSuccessfulBuild/artifact/build/libs/PlaceholderAPI-2.11.2-DEV-148.jar https://ci.codemc.io/view/Author/job/pop4959/job/Chunky/lastSuccessfulBuild/artifact/bukkit/build/libs/Chunky-1.2.165.jar https://ci.ender.zone/job/EssentialsX/lastSuccessfulBuild/artifact/jars/EssentialsX-2.19.3-dev+6-739600e.jar https://ci.ender.zone/job/EssentialsX/lastSuccessfulBuild/artifact/jars/EssentialsXChat-2.19.3-dev+6-739600e.jar https://ci.ender.zone/job/EssentialsX/lastSuccessfulBuild/artifact/jars/EssentialsXSpawn-2.19.3-dev+6-739600e.jar        ufw allow 25565 2> /dev/null
        echo -e "127.0.0.1\tbstats.org" >> /etc/hosts
        printf "\n[$(tput setaf 2)✓$(tput sgr 0)] Installation réussie de Minecraft\n"
        ;;
esac
read -r -p "Voulez-vous installer Nginx Proxy Manager ? [O/n] " response
case "$response" in
    [oO][eE][sS]|[oO]) 
        docker run -d --restart=always -p 81:81 -p 80:80 -p 443:443 -e PUID=$(id -u) -e PGID=$(id -u) jc21/nginx-proxy-manager:latest
        printf "\n[$(tput setaf 2)✓$(tput sgr 0)] Installation réussie de Nginx Proxy Manager\n"
        ufw allow 80 2> /dev/null
        ufw allow 443 2> /dev/null
        printf "— $(tput setaf 3)http://%s$(hostname -I | awk '{print $1}'):81\n$(tput sgr 0)"
        ;;
esac
read -r -p "Voulez-vous installer Speedtest CLI ? [O/n] " response
case "$response" in
    [oO][eE][sS]|[oO]) 
        curl -sSL https://packagecloud.io/ookla/speedtest-cli/gpgkey | gpg --dearmor | sudo tee /usr/share/keyrings/speedtestcli-archive-keyring.gpg >/dev/null
        echo "deb [signed-by=/usr/share/keyrings/speedtestcli-archive-keyring.gpg] https://packagecloud.io/ookla/speedtest-cli/debian/ $(lsb_release -cs) main" | sudo tee  /etc/apt/sources.list.d/speedtest.list
        apt update && apt install -y speedtest
        printf "\n[$(tput setaf 2)✓$(tput sgr 0)] Installation réussie de Speedtest CLI\n"
        ;;
esac
read -r -p "Voulez-vous installer Uptime Kuma ? [O/n] " response
case "$response" in
    [oO][eE][sS]|[oO]) 
        docker run -d --restart=always -p 3001:3001 -e PUID=$(id -u) -e PGID=$(id -u) louislam/uptime-kuma:latest
        printf "\n[$(tput setaf 2)✓$(tput sgr 0)] Installation réussie de Uptime Kuma\n"
        ufw allow 3001 2> /dev/null
        printf "— $(tput setaf 3)http://%s$(hostname -I | awk '{print $1}'):3001\n$(tput sgr 0)"
        ;;
esac
read -r -p "Voulez-vous installer zRam ? [O/n] " response
case "$response" in
    [oO][eE][sS]|[oO]) 
        git clone -q https://github.com/foundObjects/zram-swap && cd zram-swap || exit
        ./install.sh
        printf "\n[$(tput setaf 2)✓$(tput sgr 0)] Installation réussie de zRam\n"
        ;;
esac
read -r -p "Voulez-vous modifier /boot/config.txt ? [O/n] " response
case "$response" in
    [oO][eE][sS]|[oO]) 
        sed -i 's/#arm_freq/arm_freq/g' /boot/config.txt
        sed -i 's/#over_voltage=/over_voltage=/g' /boot/config.txt
        sed -i 's/#gpu_freq/gpu_freq/g' /boot/config.txt
        sed -i 's/arm_freq=.*/arm_freq=2147/' /boot/config.txt
        sed -i 's/over_voltage=.*/over_voltage=6/' /boot/config.txt
        sed -i 's/gpu_freq=.*/gpu_freq=750/' /boot/config.txt
        printf "\n[$(tput setaf 2)✓$(tput sgr 0)] Edition réussie de config.txt\n"
        ;;
esac
read -r -p "Voulez-vous modifier /etc/ssh/sshd_config ? [O/n] " response
case "$response" in
    [oO][eE][sS]|[oO]) 
        sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
        printf "\n[$(tput setaf 2)✓$(tput sgr 0)] Edition réussie de ssh\n"
        ;;
esac
read -r -p "Voulez-vous changer la langue en français ? [O/n] " response
case "$response" in
    [oO][eE][sS]|[oO]) 
        update-locale LANG=fr_FR.UTF-8
        printf "\n[$(tput setaf 2)✓$(tput sgr 0)] Le changement de langue est terminé\n"
        ;;
esac
read -r -p "La configuration est terminée, voulez-vous redémarrer maintenant ? [O/n] " response
case "$response" in
    [oO][eE][sS]|[oO]) 
        apt -y autoclean && apt -y autoremove
        i=60;while [ $i -gt 0 ];do if [ $i -gt 9 ];then printf "\b\b$i";else  printf "\b\b $i";fi;sleep 1;i=$(expr $i - 1);done
        printf "\n"
        ;;
    *)
        exit 0
        ;;
esac
/sbin/reboot now