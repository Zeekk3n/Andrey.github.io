---
layout: single
title: '<span class="projects">Hill Cipher - Project</span>'
excerpt: "The Hill cipher was proposed by Lester S. Hill in 1929, which is a polygraph substitution cryptosystem that uses the product of matrices to perform operations based on using a matrix as a key to encrypt a plaintext and its inverse to decrypt the corresponding cryptogram."
date: 2021-03-11
categories:
  - projects
tags:  
  - python
  - cipher
show_time: true
---

The Hill cipher was proposed by Lester S. Hill in 1929, which is a polygraph substitution cryptosystem that uses the product of matrices to perform operations based on using a matrix as a key to encrypt a plaintext and its inverse to decrypt the corresponding cryptogram.

## [Link to the Github repository](https://github.com/shockz-offsec/Cifrado-de-Hill)

## Operation

Take a look Wikipedia [Hill's cipher](https://es.wikipedia.org/wiki/Cifrado_Hill)

An alphabet of 41 characters has been used, 26 letters of the English alphabet, 10 numeric digits, from 0 to 9, as well as the following 4 characters: ```.``` , ```,``` , ```:``` , ```?``` and the blank space, in that order.

Each letter is represented by a number (dictionary).

## Functions:

### Generate the key

A square matrix (n x n) with random values will be generated.

### Encryption

Each block of n letters (considered as a vector) is converted into a vector of numbers (its corresponding representation in the dictionary), this is multiplied by an invertible matrix n×n (key) to which its product is applied the module 41 and then the inverse dictionary is applied, thus returning a text string with the message encrypted by that key.

It is necessary to consider that in case the text to be encrypted is smaller than the size of the key, we will padding with the character 'X'. In case the text to be encrypted is larger than the key size, we will divide the text into blocks of the key size and encrypt them one by one and unify them in a single variable.

Example :

```
key: [[33, 1, 7], [40, 32, 24], [12, 22, 19]]]
message: SECRET TEXT
returns: :9OB8:OI5,4Y
```

### Decryption

Each block is converted into a vector of letters with the dictionary and this is multiplied by the inverse of the matrix used for the encryption and then to each term is applied the module 41 and finally decrypted using the inverse dictionary.

It is necessary to consider that the 'X' used in the encryption must be eliminated.

```
key: [[33, 1, 7], [40, 32, 24], [12, 22, 19]]]
ciphertext: :9OB8:OI5,4Y
returns: SECRET TEXT
```

# Test Environment

The file ```Test_Hill.py``` is provided, which contains several tests of the various functions.
