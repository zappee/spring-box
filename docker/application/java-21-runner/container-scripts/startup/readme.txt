Scripts in the docker.startup directory run in alphabetical order EVERY time
the container starts up, including after restarts and reboots. Scripts must
be executable (e.g., chmod +x *.sh).