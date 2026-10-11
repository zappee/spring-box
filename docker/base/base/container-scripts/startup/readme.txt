Scripts in `docker.startup` directory run EVERY time (in alphabetical order) the container starts up, including after restarts and reboots.
Scripts must be set as executable (`chmod +x *.sh`).