---
layout: single
title: '<span class="projects">Reactions - Project</span>'
excerpt: "Reactions is an application with which you can test your reflexes and get in milliseconds or seconds your reaction speed. The application was made with the Flutter framework and programmed in Dart."
date: 2020-09-29
categories:
  - projects
tags:  
  - app
  - dart
  - flutter
  - ios
  - android
toc: true
toc_label: "Content"
toc_sticky: true
show_time: true
---

Reactions is an application with which you can test your reflexes and get in milliseconds or seconds your reaction speed. The application was made with the Flutter framework and programmed in Dart.

This framework powered by Google allows applications created in Flutter to be taken to Android, iOS, Windows, Mac, Linux and the web, without the need to make changes to the code.

## [Link to the Github repository](https://github.com/jmlgomez73/Reactions)

## Design

* BLoC Pattern - To separate the logic from the interface.
* Dart StreamController - To communicate UI intents.
* Flutter StreamBuilder - To trigger UI updates.


<h1 align="center">Features</h1>

## Number of players

### 1 Player

* The best results you obtain will be saved in the Statistics section.

### 2 Players

* You will each have your own screen.

* You will each have your own screen. Hit the center button to start and after getting each result to continue, if your mode is Best of 3 or Best of 5. In this case no stats will be saved.
  
## Modes

### Test

* Here you will have one try.
  After hitting Start, when the screen turns green, click as fast as you can.

### Best of 3

* You have 3 attempts.
  You will get results after each one and at the end you will get an average.
  
### Best out of 5

* You have 5 attempts.
  You will get results after each one and at the end you will get an average.

## Functions
  
* Beat your record!!! The lower it is the faster you are!!!
  * Statistics system accessible from the bottom bar of the application.
  * Highscore measured in seconds or milliseconds for each mode (Only for 1 Player mode).
    
* Record saving
  * Storage of records in shared preferences.
  * Records retrieval at application startup.
  * JSON encoding and decoding.

* Lower navigation menu.
  * Access to Statistics, Information or return to the initial Menu.
    
* Interesting information and study on human reflexes and reaction times.

## Demostration

<a href="/assets/images/project-reactions/1.gif">
    <img src="/assets/images/project-reactions/1.gif">
</a>