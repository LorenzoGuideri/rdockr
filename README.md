# Rdockr

Control your docker containers on your remote server from plasma applet.

> [!NOTE] This extension use custom icon, you need to [copy](#icons) contents
> from icons folder to your theme or local icons folder.
>
> To use the plasmoid widget effectively, it is essential to run Docker without
> requiring sudo privileges.

## Features

- List all available containers
- Start, Stop, Restart and Delete containers
- Show containers info
- Inspect containers

## Package Dependencies

### Arch

```bash
sudo pacman -S curl kdeplasma-addons
```

## Installation

### Build it Yourself

```bash
git clone https://github.com/LorenzoGuideri/rdockr.git rdockr
cd rdockr
kpackagetool6 -t Plasma/Applet -i package
```

### Icons

```bash
mkdir -p ~/.local/share/icons/hicolor/scalable/status
cp -r ./icons/* ~/.local/share/icons/hicolor/scalable/status/
```

Restart plasmashell

```bash
systemctl --user restart plasma-plasmashell
```

Go to Configure System Tray > Entries > System Services then choose "Show when
relevant" or "Always shown"

### Run Docker without sudo privileges

To utilize the plasmoid widget for managing Docker containers, it's essential to
run Docker without requiring sudo privileges. This ensures that the
functionality works as expected. See
[here](https://docs.docker.com/engine/install/linux-postinstall/) for detailed
information.

Create the docker group.

```bash
sudo groupadd docker
```

Add your user to the docker group.

```bash
sudo usermod -aG docker $USER
```

Log out and log back in so that your group membership is re-evaluated.
