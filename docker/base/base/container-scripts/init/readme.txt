Scripts in the docker.init directory run in alphabetical order only ONCE during
the container's very first boot. They are skipped on all subsequent container
restarts. Scripts must be executable (e.g., chmod +x *.sh).