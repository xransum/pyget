# pyget

Quickly install a local version of Python within the users home directory `~/.local/python-<version>`.

## Usage

### Install

Installing a latest major version:
```bash
bash <(curl -skL https://raw.githubusercontent.com/xransum/pyget/main/pyget.sh) 3
```

Installing a latest minor version:
```bash
bash <(curl -skL https://raw.githubusercontent.com/xransum/pyget/main/pyget.sh) 3.10
```

Installing a specific version:
```bash
bash <(curl -skL https://raw.githubusercontent.com/xransum/pyget/main/pyget.sh) 3.7.16
```

### List

List all versions:
```bash
bash <(curl -skL https://raw.githubusercontent.com/xransum/pyget/main/pyget.sh) --list
```

List either major, minor, or patch version:
```bash
bash <(curl -skL https://raw.githubusercontent.com/xransum/pyget/main/pyget.sh) 3 --list
bash <(curl -skL https://raw.githubusercontent.com/xransum/pyget/main/pyget.sh) 3.1 --list
bash <(curl -skL https://raw.githubusercontent.com/xransum/pyget/main/pyget.sh) 3.9.12 --list
```
