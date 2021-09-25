---
layout: single
title: '<span class="projects">TV Time - Project</span>'
excerpt: "This script shows you how long it has taken you to watch a series or all your favorite series."
date: 2021-02-02
categories:
  - projects
tags:  
  - python
show_time: true
---

This script shows you how long it has taken you to watch a series or all your favorite series.

A series.txt file is required in the root directory of the application with the list of series to be processed. These will dump the results in an xlsx file, also the incompatibility errors when searching for the series will be dumped in the errors.txt file.

## [Link to the Github repository](https://github.com/jmlgomez73/TVTime)

## Design

* **Pandas** was used to export the dataframe with the data.
* **Requests** for the requests.
* **openpyxl** for the input/output of xlsx files.