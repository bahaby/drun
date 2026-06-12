# 🐳 drun

A lightweight, zero-friction directory-based Docker Compose wrapper for local development. It automates directory jumping, handles custom `.yml` files, maps your environment layout, and provides global lifecycle controls.

> **Note:** This tool was created primarily for my own personal use, but if it fits your workflow, feel free to use it, fork it, or adapt it to your needs!

---

## 🚀 Quick Install

Run the one-liner below to download `drun`, configure your `PATH` automatically, and set up your environment shell layout:

```bash
curl -fsSL https://raw.githubusercontent.com/bahaby/drun/main/install.sh | bash
```
Note: Restart your terminal or run source ~/.bashrc (or your respective shell config file) after installation to apply changes.

⚙️ Configuration
By default, drun looks for your project stacks inside $HOME/docker. You can permanently change this to any custom folder using the script itself:

```bash 
drun --set-home /home/user/Code/Docker
```

🛠️ Usage & Examples
drun dynamically maps subdirectories to project names. If a subdirectory contains a docker-compose.yml file, you can interact with it instantly from anywhere.

Structure Example

```
/home/user/Code/Docker/
├── open-webui/
│   └── docker-compose.yml
└── speaches/
    ├── docker-compose.yml
    └── dev.yml
```

Standard Commands

```bash
drun open-webui up -d     # Jump to open-webui/ and start containers detached
drun open-webui logs -f   # Tail live logs for open-webui
drun open-webui down      # Stop and remove the open-webui stack
```

Alternative Config Profiles
If you have custom profiles (like dev.yml or test.yaml), pass the file prefix right after the folder name:

```bash
drun speaches dev up -d   # Executes: docker compose -f dev.yml up -d
```

📊 Management Commands
Keep tabs on your entire local docker ecosystem with these global flags:

- List Stacks: ```drun -l``` or ```drun --list```

    Scans your base folder and prints a structural breakdown of all directories containing valid yaml files.

- Global Status: ```drun -s``` or ```drun --status```

    Displays which of your local managed stack directories are running (🟢) or idle (🔴), followed by standard global container system stats.

- Stop Everything: ```drun --stop-all```

    Prompts a confirmation warning and safely loops through every managed stack folder to run docker compose down. Perfect for freeing up system resources quickly.

- Self Update: ```drun --update```

    Pulls the latest script code down directly from this GitHub repository while perfectly preserving your custom home folder configurations.