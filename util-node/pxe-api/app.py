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
    hostname = ""
    arch = None
    build = "latest"
    app.logger.debug(f"got mac of '{mac}'")

    if mac in [ "00:1e:06:45:28:5c", "00:1e:06:45:28:5d" ]:
        hostname = "w1"
        arch = "x86_64"
        build = "latest"
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
        "kernel": f"{fileServer}/{arch}/{build}/vmlinuz",
        "initrd": [f"{fileServer}/{arch}/{build}/initrd.img"],
        "cmdline": " ".join(
            [
                "boot=ramdisk",
                f"hostname={hostname}",
                f"ramroot={fileServerIP}/{arch}/{build}/ramroot.tar.xz",
            ]
        ),
    }

    app.logger.debug(r)
    return json.dumps(r)


if __name__ == "__main__":
    app.run(host="0.0.0.0")
