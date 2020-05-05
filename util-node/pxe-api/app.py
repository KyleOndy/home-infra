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
    kernel = ""
    initrds = []
    cmdline = ""
    hostname = ""
    arch = None
    app.logger.debug(f"got mac of '{mac}'")

    if mac in [ "00:1e:06:45:28:5c", "00:1e:06:45:28:5d" ]:
        hostname = "w1"
        arch = "x86_64"
        app.logger.debug(f"booting x86 for {hostname} ({mac})")

    elif mac in [ "00:1e:06:45:20:02", "00:1e:06:45:20:03" ]:
        hostname = "w2"
        arch = "x86_64"
        app.logger.debug(f"booting x86 for {hostname} ({mac})")

    elif mac in [ "00:1e:06:45:2e:ec", "00:1e:06:45:2e:ed" ]:
        hostname = "w3"
        arch = "x86_64"
        app.logger.debug(f"booting x86 for {hostname} ({mac})")

    elif mac in ["dc:a6:32:55:33:40"]:
        arch = "armfh"
        app.logger.debug(f"booting armfh for '{mac}'")
    else:
        app.logger.debug(f"no definition for '{mac}' found")
        abort(404)

    r = {
        "kernel": f"{fileServer}/{arch}/vmlinuz",
        "initrd": [f"{fileServer}/{arch}/initrd.img"],
        "cmdline": " ".join(
            [
                #"root=ram",
                #"rootfstype=ramdisk",
                #"simplenet=1",
                #"verbose",
                #"udev.children-max=4",
                #"rootpw=nyble",
                #"ramdisktype=zram",
                #"ramdisksize=24"
                #f"initrd={fileServer}/{arch}/initrd.img",
                #"initrd=initrd.img",
                "boot=ramdisk",
                f"hostname={hostname}",
                f"ramroot={fileServerIP}/{arch}/ramroot.tar.xz",
                #"boot=live",
                #f"fetch={fileServer}/{arch}/filesystem.squashfs",
                #"ethdevice=eth0",
                #"root=/dev/ram0",
            ]
        ),
    }

    app.logger.debug(r)
    return json.dumps(r)


if __name__ == "__main__":
    app.run(host="0.0.0.0")
