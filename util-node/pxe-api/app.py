from flask import Flask, abort
from flask import render_template
import json
import logging


app = Flask(__name__)
fileServer = "http://util.dmz.509ely.com:8080"
fileServerIP = "http://10.25.89.4:8080"


logging.basicConfig(level=logging.DEBUG)


@app.route("/v1/boot/<mac>")
def boot(mac):
    # todo: move this into a config file
    kernel = ""
    initrds = []
    cmdline = ""
    role = ""
    hostname = ""
    arch = None
    build = "latest"
    app.logger.debug(f"got mac of '{mac}'")

    if mac in ["00:1e:06:45:28:5c", "00:1e:06:45:28:5d"]:
        hostname = "w1"
        arch = "amd64"
        build = "latest"
        role = "worker"
        app.logger.debug(f"booting x86 for {hostname} ({mac})")

    elif mac in ["00:1e:06:45:20:02", "00:1e:06:45:20:03"]:
        hostname = "w2"
        arch = "amd64"
        build = "latest"
        role = "worker"
        app.logger.debug(f"booting x86 for {hostname} ({mac})")

    elif mac in ["00:1e:06:45:2e:ec", "00:1e:06:45:2e:ed"]:
        hostname = "w3"
        arch = "amd64"
        build = "latest"
        role = "worker"
        app.logger.debug(f"booting x86 for {hostname} ({mac})")

    elif mac in ["dc:a6:32:55:33:40"]:
        hostname = "m1"
        arch = "arm64"  # todo: armfh vs arm64?
        build = "latest"
        role = "server"
        app.logger.debug(f"booting armfh for '{mac}'")
    else:
        app.logger.debug(f"no definition for '{mac}' found")
        abort(404)

    kernel = "vmlinuz" if build == "latest" else f"{build}.vmlinuz"
    initrd = "initrd.img" if build == "latest" else f"{build}.initrd.img"
    ramroot = "ramroot.tar.xz" if build == "latest" else f"{build}.ramroot.tar.xz"

    r = {
        "kernel": f"{fileServer}/{role}/{arch}/{kernel}",
        "initrd": [f"{fileServer}/{role}/{arch}/{initrds}"],
        "cmdline": " ".join(
            [
                "console=serial0,115200",  # this breaks the boot?
                "console=tty1",
                ## from https://www.raspberrypi.org/documentation/configuration/uart.md
                # "earlycon=pl011,mmio32,0xfe201000",
                "rootdelay=5",  # this can be removed once things are working
                "panic=60",  # reboot 10 seconds after panic
                # "debug",
                "keep_bootcon",
                # "uefi_debug",
                # "ignore_loglevel",
                # "dtb=bcm2711-rpi-4-b",
                "boot=ramdisk",
                f"BOOTIF={mac}",
                f"hostname={hostname}",
                f"ramroot={fileServerIP}/{role}/{arch}/{arch}/{ramroot}",
            ]
        ),
    }

    app.logger.debug(r)
    return json.dumps(r)


if __name__ == "__main__":
    app.run(host="0.0.0.0")
