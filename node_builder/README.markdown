# Node Builder

## Usage

Starting with a new chroot
```bash
# build source chroot
src_chroot=$(mktemp -d)
./bin/generate_chroot $src_chroot <pkgs>
```

Iterating on provisioning
```bash
new_chroot=$(mktemp -d)
./bin/copy_chroot $src_chroot $new_chroot
./make_node $new_chroot
```

## Naming

Precedence of naming components.
The `-` could be any delimiter.

`<role>-<arch>-<component>`

## Todo / Roadmap

- Block nomad until glusterfs has replicated

## Modules

I am not using any configuration management system. Just good old bash.

Each discreet thing (module) gets a folder under [`modules`](./modules) with an `install` script.
I choose to use reasonable defaults, only myself to blame if I later determine they are insane, and prompt only if really needed.

## External Resources

Getting this all to work was quite a journey.
The following resources were all invaluable for gluing everything together.

- [Medallia's ramroot project](https://github.com/medallia/ramroot) for initramfs-tools.
- [spikedrba's notses on ramroot](https://gist.github.com/spikedrba/057acad8b3bfb0266544347ced8b53d4)
