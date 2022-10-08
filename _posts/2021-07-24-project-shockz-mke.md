---
layout: single
title: '<span class="projects">Shockz MKE - Project</span>'
excerpt: "Shockz MKE is my professional working environment focused on pentesting and Capture The Flag. It has several utilities like a custom prompt style with powerlevel10k, several topbars with some useful functionality thanks to polybar, etc. It also contains personal settings, scripts, dictionaries, shortcuts and tools needed in case it is installed on virtual machines."
date: 2021-07-24
categories:
  - projects
tags:  
  - zsh
  - linux
  - pentesting
  - kali-linux
  - bspwm
  - environment
show_time: true
---

Shockz MKE is my professional working environment focused on pentesting and Capture The Flag. It has several utilities like a custom prompt style with powerlevel10k, several topbars with some useful functionality thanks to polybar, etc. It also contains personal settings, scripts, dictionaries, shortcuts and tools needed in case it is installed on virtual machines.

Feel free to take advantage of my scripts or configuration files.

Remember this is made to work for my specific user so if you want to use it for yourself you will have to edit a lot of files.

## [Link to the Github repository](https://github.com/jmlgomez73/Shockz-MKE)

## Tested on the following Linux distributions:
- Kali Linux 2022.3
- Kali Linux 2022.1
- Kali Linux 2021.2
- Kali Linux 2020.4

### Features I use in my Kali VM's

* **CPU**
    * 2 Cores y 8 Threads
* **RAM**
    * 12GB
* **VHD**
    * 90 GB
* **Partitions**
    * Primaria
      * / = 50 GB
    * Lógica
      * /home = 20 GB
      * /var = 15 GB
      * /swap = 5 GB

## Installation:
> It is recommended to install to a new ISO. If this is not possible, that is, if you are using a used, cloned or preconfigured virtual machine, I recommend making a snapshot of the current state of the machine, because it can generate problems and/or conflicts in the course of the installation. The solution to this is beyond my scope.


**1)** We change to the root user
```bash
sudo su
```
**2)** Clone the repository, give execute permissions to the install.sh file and run it.

```bash
git clone https://github.com/jmlgomez73/Shockz-MKE && cd Shockz-MKE && chmod +x install.sh && ./install.sh
```
**3)** Reboot and select as launcher bspwm


## General view

<a href="/assets/images/project-shockz-mke/1.png">
    <img src="/assets/images/project-shockz-mke/1.png" alt="shockz mke">
</a>

<a href="/assets/images/project-shockz-mke/2.png">
    <img src="/assets/images/project-shockz-mke/2.png" alt="shockz mke 1">
</a>

## Utilities:
- **bspwm**: Tiling Window Manager. Author: [baskerville](https://github.com/baskerville)
- **zsh**: Shell.
- powerlevel10k**: Zsh theme. Author: [romkatv](https://github.com/romkatv)
- **sxhkd**: A "daemon" that listens for keyboard events and executes commands. Author: [baskerville](https://github.com/baskerville)
- **polybar**: Quick and easy to use tool to create status bars.
- **polybar-themes**: Themes for polybar. Author: [VaughnValle](https://github.com/VaughnValle)
- picom**: Composer for X11. Author: [yshui](https://github.com/yshui)
- profi**: Window selector and application launcher.
- **feh**: Visor de imágenes ligero, configurable y versátil.
- **Hack Nerd Font**: Fuente.
- **fzf**: Buscador difuso de línea de comandos de propósito general. Autor: [junegunn](https://github.com/junegunn)

## Shortcuts (atajos de teclado)

```Windows + Enter``` : Abrir la consola (gnome-terminal).

```Windows + W``` : Cerrar la ventana actual.

```Windows + Alt + R``` : Reiniciar la configuración del bspwm.  

```Windows + Alt + Q``` : Cerrar sesión.  

```Windows + (⬆⬅⬇➡)``` : Moverse por las ventanas en la workspace actual.  

```Windows + D``` : Abrir el Rofi. Esc para salir.

```Windows + D + escribir ```thunar```:  Abrir explorador de archivos.

```Windows + (1,2,3,4,5,6,7,8,9,0)``` : Cambiar el workspace.

```Windows + T``` : Cambiar la ventana actual a modo "terminal" (normal). Nos sirve cuando la ventana está en modo pantalla completa o flotante.  

```Windows + M``` : Cambiar la ventana actual a modo "completo" (no ocupa la polybar). Presione la mismas teclas para volver a modo "terminal" (normal).  

```Windows + F``` : Cambiar la ventana actual a modo pantalla completa (ocupa todo incluyendo la polybar). 

```Windows + S``` : Cambiar la ventana actual a modo "flotante".  

```Windows + Alt + (1,2,3,4,5,6,7,8,9,0)``` : Mover la ventana actual a otro workspace.  

```Windows + Alt + (⬆⬅⬇➡)``` : Cambiar el tamaño de la ventana actual (solo funciona si está en modo terminal o flotante).  

```Windows + Ctrl + (⬆⬅⬇➡)``` : Cambiar la posición de la ventana actual (solo funciona en modo flotante). 

```Windows + Shift + G``` : Abrir Google Chrome (es necesario instalarlo primero).  

```Windows + Ctrl + Alt + (⬆⬅⬇➡)``` : Mostrar una preselección para luego abrir una ventana (una terminal, Google Chrome, un archivo, etc.). 

```Windows + Ctrl + Space``` para deshacer la preselección.  

#### Atajos zsh

```Ctrl + A``` : Principio de línea

```Ctrl + E``` : final de línea

```Ctrl + L``` : Limpiar consola

```Alt + Q``` : Borra toda la línea

```Alt + Backspace``` : Elimina la palabra anterior al cursor

```Alt + D``` : Elimina la palabra posterior al cursor

```Ctrl + K``` : Elimina todo lo que hay detrás del cursor

```Ctrl + D``` : Funciona igual que la tecla suprimir

```Ctrl + U``` : Elimina la línea entera y la guarda en el framebuffer

```Ctrl + Y``` : Pega el frambuffer

## Funcionalidades y Atajos

* Display several options to choose from among the files in the current directory. 

  ```rm **``` + Tab

* Smart path autocompleter

  If we type ```cd /u/s/w``` => tabbing changes to ```cd /usr/share/wordlists```.

* Smart search for files and directories

  ```Ctrl + T```

* Search in the command history

  ```Ctrl + R```

* Long listing showing hidden files

  ```la```

* Creation of a directory structure ideal for test instructions (Pentest/CTF's)

  ```mkt```

* Deep file deletion

  ```rmk```

* Set an IP as a target

  ```settarget <IP>```

* Clear IP set as target

  ```cleartarget```

* sudo autocompleter

  Type a command and press ```Esc + Esc``` , it will appear in front of the command ```sudo```.

* Visual file explorer browser

  ```ranger```

* Set a port to listen and get a reverse shell, then get a 100% interactive TTY shell (Works for Linux only)

  ```tty <port>````

> Note that when we refer to the Windows key, it may change depending on the selected pointer_modifier, which is found in the ~/.config/bspwm/bspwmrc file.

## Manual configuration
- Edit the code to taste