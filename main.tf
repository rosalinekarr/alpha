terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.15.0"
    }
  }
}

provider "docker" {}

resource "docker_image" "transmission" {
  name         = "ghcr.io/linuxserver/transmission"
  keep_locally = false
}

resource "docker_image" "samba" {
  name         = "dperson/samba"
  keep_locally = false
}

resource "docker_image" "minidlna" {
  name         = "vladgh/minidlna"
  keep_locally = false
}

resource "docker_image" "home-assistant" {
  name         = "ghcr.io/home-assistant/home-assistant"
  keep_locally = false
}

resource "docker_container" "transmission" {
  image = "${docker_image.transmission.latest}"
  name  = "transmission"
  env = ["PUID=0", "PGID=0", "TZ=America/New_York", "USER=rosalinekarr", "PASS=wat77ghbW7EHW4abPmhHDYxQAEU3MtpPMWtZDMFWEmHBkMUcXrwFrYq8j8KaghazQUsAYZcdskRwCyupZz7L99q62LMrnLWB3vmV"]
  restart = "unless-stopped"
  volumes {
    host_path = "/root/config/transmission"
    container_path = "/config"
  }
  volumes {
    host_path = "/media/barracuda/media"
    container_path = "/downloads"
  }
  ports {
    internal = 9091
    external = 9091
  }
  ports {
    internal = 51413
    external = 51413
  }
  ports {
    internal = 51413
    external = 51413
    protocol = "udp"
  }
}

resource "docker_container" "samba" {
  image = "${docker_image.samba.latest}"
  name  = "samba"
  command = ["-p", "-u", "rosalinekarr;pc4gUAhiKEhiiXEExv9kpTPxmdQGXZBfji4u422JNfbcMk3gXdkJWCRmY6eZDhcHDfvUbowru6QRs9YyjwEvQaa3bDpZcs2Kz2GD", "-s", "alpha;/alpha;yes;no;no"]
  restart = "unless-stopped"
  volumes {
    host_path = "/media/barracuda"
    container_path = "/alpha"
  }
  ports {
    internal = 139
    external = 139
  }
  ports {
    internal = 445
    external = 445
  }
}

resource "docker_container" "minidlna" {
  image = "${docker_image.minidlna.latest}"
  name  = "minidlna"
  env = ["MINIDLNA_MEDIA_DIR=/media", "MINIDLNA_FRIENDLY_NAME=ALPHA"]
  network_mode = "host"
  restart = "unless-stopped"
  volumes {
    host_path = "/media/barracuda/media/complete"
    container_path = "/media"
  }
}

resource "docker_container" "home-assistant" {
  image = "${docker_image.home-assistant.latest}"
  name  = "home-assistant"
  network_mode = "host"
  privileged = true
  init = true
  restart = "unless-stopped"
  volumes {
    host_path = "/etc/localtime"
    container_path = "/etc/localtime"
    read_only = true
  }
  volumes {
    host_path = "/root/config/homeassistant"
    container_path = "/config"
  }
}
