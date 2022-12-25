cd /opt
rm -rf ./video-mitm
mkdir video-mitm
cd video-mitm
wget https://github.com/kontorol/good-mitm/releases/download/0.4.1/video-mitm-0.4.0-x86_64-unknown-linux-gnu.tar.xz
xz -d ./video-mitm-0.4.0-x86_64-unknown-linux-gnu.tar.xz
tar -xvf ./video-mitm-0.4.0-x86_64-unknown-linux-gnu.tar
rm -rf ./video-mitm-0.4.0-x86_64-unknown-linux-gnu.tar.xz ./video-mitm-0.4.0-x86_64-unknown-linux-gnu.tar

wget --no-check-certificate https://raw.githubusercontent.com/kontorol/good-mitm/main/rules/netflix.yaml
./video-mitm genca

wget --no-check-certificate https://raw.githubusercontent.com/kontorol/good-mitm/main/video-mitm.service.template -O ./video-mitm.service
ln -s $(pwd)/video-mitm.service /etc/systemd/system/video-mitm.service
ln -s ./$(pwd)/video-mitm /usr/bin/video-mitm

systemctl enable --now video-mitm.service
systemctl daemon-reload

FILE=/usr/local/x-ui/bin/config.json
if test -f "$FILE"; then
    read -p "Are you sure? " -n 1 -r
    echo    # (optional) move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        # do dangerous stuff
        mv /usr/local/x-ui/bin/config.json /usr/local/x-ui/bin/config.json.bak
        wget --no-check-certificate https://raw.githubusercontent.com/kontorol/good-mitm/main/x-ui.json.template -O ./x-ui.json
        ln -s $(pwd)/x-ui.json /usr/local/x-ui/bin/config.json
    fi
fi





