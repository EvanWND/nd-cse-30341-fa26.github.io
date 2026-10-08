---
title: "Notebook 11-B: Semaphores"
description: "Semaphores"
author: Peter Bui
keywords: notebook,osp,threads,semaphores,rate-limiting,throttling,barrier
url: https://pnutz.h4x0r.space/courses/cse.30341.fa26/notebook10.html
theme: domer-slides
---

<!-- _class: lead -->

# CSE 30341

## Semaphores

---

# Project 02: <span class="gold">Chat Application</span>

<div class="slide-centered">

<img src="static/img/project02-chat-application.svg" height="600px">

</div>

---

# Semaphores: <span class="gold">Overview</span>

A <strong class="special">semaphore</strong> is a **synchronization primitive**
that consists of an

<strong class="caution"> __________________</strong> that we can manipulate
with two <strong class="success">operations</strong>:

<div class="columns">

<div>

```python
def sem_wait(s):







```

</div>

<div>

```python
def sem_post(s):







```

</div>

</div>

---

# Reading 05: <span class="gold">Producer / Consumer</span>

<div class="centered">

<img src="static/img/slides10-producer-consumer.svg" width="400px">

</div>

- We want to check condition <strong class="special">semaphores</strong>
  <strong> ______________________</strong> *acquiring* lock
  <strong class="special">semaphore</strong>.

    <br>

- Need to release lock <strong class="special">semaphore</strong>
  <strong> _____________________________</strong> *signaling* conditions.

[modify]: https://github.com/nd-cse-30341-fa26/examples/tree/master/lecture11

---

# Reading 06: <span class="gold">Rate Limiting</span>

> To prevent the a **denial-of-service**, we can use the **rate limiting** or
> **throttling** pattern: allow up to `N` active tasks before forcing new tasks
> to wait.

---

# Semaphores: <span class="gold">Reader-Writer Locks</span>

With <strong class="special">semaphores</strong>, we can create interesting
synchronization objects such as <strong class="danger">reader-writer
locks</strong>:

- Once <strong class="success">readers</strong> acquire the <strong
  class="warning">writelock</strong>,<br>

    <strong> ___________________________________________________________</strong>

    <br>

- Once a <strong class="danger">writer</strong> acquires the <strong
  class="warning">writelock</strong>,<br>

    <strong> ___________________________________________________________</strong>

    <br>

- Unfortunately, this can add
  <strong class="caution"> _______________________________</strong>

  and is prone to
  <strong class="danger"> __________________________________________</strong>.

---

# Semaphores: <span class="gold">Reader Preference</span>

<div class="columns">

<div>

```c
size_t Readers    = _______________
sem_t  WriterLock = _______________
sem_t  ReaderLock = _______________

Writer():
    sem_wait(_____________________)
    do_write()
    sem_post(_____________________)
```

<br>

- <strong class="success">Pro</strong>: <strong> ______________________</strong>

    <br>

- <strong class="danger">Con</strong>:  <strong> ______________________</strong>

</div>

<div>

```c
Reader():
    sem_wait(____________________)
    if __________________________:
        sem_wait(________________)
    ______________________________
    sem_post(____________________)

    do_read()

    sem_wait(____________________)
    ______________________________
    if __________________________:
        sem_post(________________)
    sem_post(____________________)
```

</div>

</div>

---

# Semaphores: <span class="gold">Fair</span>

<div class="columns">

<div>

```c
size_t Readers      = 0
sem_t  WriterLock   = 1
sem_t  ReaderLock   = 1
_______________________________

Writer():
    ___________________________
    sem_wait(&WriterLock)
    ___________________________
    do_write()
    sem_post(&WriterLock)
```

</div>

<div>

```c
Reader():
    ________________________
    sem_wait(&ReaderLock)
    if Readers == 0:
        sem_wait(WriterLock)
    Readers++
    ________________________
    sem_post(&ReaderLock)

    do_read()

    sem_wait(&ReaderLock)
    Readers--
    if Readers == 0:
        sem_post(WriterLock)
    sem_post(&ReaderLock)
```

</div>

</div>

---

# Semaphores: <span class="gold">Summary</span>

<strong class="special">Semaphores</strong> are another useful and flexible
synchronization primitive:

- Good when you need a
  <strong class="danger"> _______________________</strong> or want to have

    <strong class="danger"> _______________________</strong> access to a resource.

    <br>

- Unlike <strong class="warning">locks</strong> and <strong
  class="caution">condition variables</strong>, there is no notion of

    <strong class="primary"> _____________________________________</strong>.

    <br>

- Can avoid using <strong class="warning">locks</strong> and <strong
  class="caution">condition variables</strong> if desired.

---

# Example: <span class="gold">Salsa Night</span>

> Suppose you and your friends are going to Salsa night hosted by our beloved
> Ramzi. You are willing to dance, but only after at **least 2** of your friends
> have started dancing.

Model this synchronization problem using POSIX **threads** and **semaphores**.
Assume each person is represented as a **thread** that calls one of the
corresponding functions below (`you_dance()` for yourself and `friend_dance()`
for each of your friends).

```c
size_t MIN_FRIENDS = 2 // Minimum number of friends dancing before you will dance
size_t Friends     = 0 // Number of friends dancing
```
