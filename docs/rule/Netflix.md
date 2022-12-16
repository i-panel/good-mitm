# Tutorial documentation

# Install X-UI:
install:
```shell
bash <(curl -Ls https://raw.githubusercontent.com/vaxilu/x-ui/master/install.sh)
```

To detect if Netflix is unlocked:

```shell
https://github.com/sjlleo/netflix-verify
```

Download the detection and unlocking program:
```shell
wget -O nf https://github.com/sjlleo/netflix-verify/releases/download/v3.1.0/nf_linux_amd64 && chmod +x nf
```

run:
```shell
./nf
```



# warp unlocks Netflix (WireGuard network interface mode)

project address：https://p3terx.com/archives/cloudflare-warp-configuration-script.html


Automatic configuration of WARP WireGuard dual-stack global network:
```shell
bash <(curl -fsSL git.io/warp.sh) d
```



Automatic configuration of WARP WireGuard IPv4 networks
```shell
bash <(curl -fsSL git.io/warp.sh) 4
```

Automatic configuration of WARP WireGuard IPv6 networks
```shell
bash <(curl -fsSL git.io/warp.sh) 6
```

Cloudflare WARP one-click configuration script function menu
```shell
bash <(curl -fsSL git.io/warp.sh) menu
```

# Video-MITM
project address：https://github.com/kontorol/good-mitm

Generate self-signed CA private key and certificate
```shell
./video-mitm genca
```

Run Video-MITM
```shell
./good-mitm run -r netflix.yaml
```

Run in the background:
```shell
nohup ./good-mitm run -r netflix.yaml > goodmitm.log 2>&1 &
```

# Video-MITM Configuration File

```yaml
- name: "netflix"
  mitm: "*.netflix.com"
  filters:
    url-regex: '^https:\/\/(www\.)?netflix\.com'
  actions:
    - modify-request:
        cookie:
          key: NetflixId
          value: 填入你的NetflixId
    - modify-request:
        cookie:
          key: SecureNetflixId
          value: 填入你的SecureNetflixId
    - modify-response:
        cookie:
          key: NetflixId
          remove: true
    - modify-response:
        cookie:
          key: SecureNetflixId
          remove: true
```


# X-UI configuration template

```yaml
{
  "api": {
    "services": [
      "HandlerService",
      "LoggerService",
      "StatsService"
    ],
    "tag": "api"
  },
  "inbounds": [
    {
        "listen": "127.0.0.1",
        "port": 30000, 
        "protocol": "socks", 
        "sniffing": {
            "enabled": true,
            "destOverride": ["http", "tls"]
        }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    },
    {
        "tag": "netflix_proxy",
        "protocol": "http",
        "settings": {
         "servers": [
           {
             "address": "127.0.0.1",
             "port": 34567
           }
         ]
        },
        "streamSettings": {
             "security": "none",
             "tlsSettings": {
               "allowInsecure": false
            }
        }
    },
    {
      "protocol": "blackhole",
      "settings": {},
      "tag": "blocked"
    }
  ],
  "policy": {
    "system": {
      "statsInboundDownlink": true,
      "statsInboundUplink": true
    }
  },
  "routing": {
    "rules": [
      {
        "type": "field",
        "outboundTag": "netflix_proxy",
        "domain": [
          "geosite:netflix"
        ]
      },
      {
        "inboundTag": [
          "api"
        ],
        "outboundTag": "api",
        "type": "field"
      },
      {
        "ip": [
          "geoip:private"
        ],
        "outboundTag": "blocked",
        "type": "field"
      },
      {
        "outboundTag": "blocked",
        "protocol": [
          "bittorrent"
        ],
        "type": "field"
      }
    ]
  },
  "stats": {}
}
```

# Certificate Detection Tool: 
https://docs.microsoft.com/zh-cn/sysinternals/downloads/sigcheck

