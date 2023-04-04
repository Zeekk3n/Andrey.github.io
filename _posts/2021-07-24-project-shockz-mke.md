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

## [Link to the Github repository](https://github.com/shockz-offsec/Shockz-MKE)

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
    * 110 GB
* **Partitions**
    * Primaria
      * / = 50 GB
    * Lógica
      * /home = 30 GB
      * /var = 25 GB
      * /swap = 5 GB

## Installation:
> It is recommended to install to a new ISO. If this is not possible, that is, if you are using a used, cloned or preconfigured virtual machine, I recommend making a snapshot of the current state of the machine, because it can generate problems and/or conflicts in the course of the installation. The solution to this is beyond my scope.


**1)** We change to the root user
```bash
sudo su
```
**2)** Clone the repository, give execute permissions to the install.sh file and run it.

```bash
git clone https://github.com/shockz-offsec/Shockz-MKE && cd Shockz-MKE && chmod +x install.sh && ./install.sh
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
- **feh**: Lightweight, configurable and versatile image viewer.
- **Hack Nerd Font**: Font.
- **fzf**: General purpose fuzzy command line search engine. Author: [junegunn](https://github.com/junegunn)

## Shortcuts (keyboard shortcuts)

```Windows + Enter``` : Open the console (gnome-terminal).

```Windows + W``` : Close the current window.

```Windows + Alt + R``` : Reset bspwm configuration.  

```Windows + Alt + Q``` : Log out.  

```Windows + (⬆⬅⬇➡)``` : Move through the windows in the current workspace.  

```Windows + D``` : Open Rofi. Esc to exit.

```Windows + D + type ```thunar``` : Open file explorer.

```Windows + (1,2,3,4,5,6,7,8,9,0)``` : Change workspace.

```Windows + T``` : Switch the current window to "terminal" (normal) mode. It is useful when the window is in full screen or floating mode.  

```Windows + M``` : Switch the current window to "full" mode (does not occupy the polybar). Press the same keys to return to "terminal" (normal) mode.  

```Windows + F``` : Switch the current window to full screen mode (occupies everything including the polybar). 

```Windows + S``` : Switch the current window to "floating" mode.  

```Windows + Alt + (1,2,3,4,5,6,7,8,9,0)``` : Move the current window to another workspace.  

```Windows + Alt + (⬆⬅⬇⬇➡)``` : Resize the current window (only works if in terminal or floating mode).  

```Windows + Ctrl + (⬆⬅⬇⬇➡)``` : Change the position of the current window (only works in floating mode). 

```Windows + Shift + G``` : Open Google Chrome (needs to be installed first).  

```Windows + Ctrl + Alt + (⬆⬅⬇⬇➡)``` : Show a preset to then open a window (a terminal, Google Chrome, a file, etc.). 

```Windows + Ctrl + Space``` to undo the preset.  

#### zsh shortcuts

```Ctrl + A``` : Beginning of line.

```Ctrl + E``` : End of line

```Ctrl + L``` : Clear Console

```Alt + Q``` : Delete all line

```Alt + Backspace``` : Delete word before cursor

```Alt + D``` : Delete the word after the cursor

```Ctrl + K``` : Deletes everything after the cursor

```Ctrl + D``` : Works like the delete key

```Ctrl + U``` : Deletes the entire line and saves it in the framebuffer

```Ctrl + Y``` : Pastes the framebuffer

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