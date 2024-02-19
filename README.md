# nodejs-no-sudo-installation

Begin by creating a shell script file named install_node_local.sh using the nano text editor:

```bash
nano install_node_local.sh
```

Within the install_node_local.sh file, paste the code from the repository you are referring to.

After pasting the code, grant execution permissions to the script using the chmod command:

```bash
chmod +x install_node_local.sh
```

Once the script has execution permissions, proceed to run the program using sudo:

```bash
sudo ./install_node_local.sh
```

This program facilitates the installation of Node.js and the n version manager without relying on sudo apt-get install node or sudo npm install n. It ensures the installation of Node.js in a dedicated directory within your base directory and n in another directory, thus avoiding potential issues associated with alternative sudo-based installations.
