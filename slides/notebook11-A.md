---
title: "Notebook 11-A: Semaphores"
description: "Semaphores"
author: Peter Bui
keywords: notebook,osp,threads,locks,condition variables,producer consumer,semaphores
url: https://pnutz.h4x0r.space/courses/cse.30341.fa26/notebook10.html
theme: domer-slides
---

<!-- _class: lead -->

# CSE 30341

## Semaphores

---

# Semaphores: <span class="gold">Questions</span>

<div class="font-large">

1. What is a <strong class="special">semaphore</strong>?

2. What <strong class="success">operations</strong> does a <strong
   class="special">semaphore</strong> provide?

3. How do we use use <strong class="special">semaphores</strong> to synchronize
   <strong class="primary">threads</strong>?

</div>

---

# Semaphores: <span class="gold">Overview</span>

A <strong class="special"> ________________________</strong> is a
**synchronization primitive** that

consists of an <strong class="caution"> __________________</strong> that
we can manipulate

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

# Example: <span class="gold">Slackline</span> (<i class="muted">Semaphores</i>)

Suppose you and your friends are <strong class="success">slacklining</strong>.
Unfortunately, the <strong class="danger">slackline can only support up to
three people on it at a time</strong>.  Therefore, if there are too many
people, the extra people will need to <strong class="caution">wait before they
can get onto the slackline</strong>.

Assuming each person performs the following procedure:

```c
get_on()            // Get on slackline if there is enough room
cross_slackline()   // Attempt to walk across slackline
get_off()           // Get off of slackline
```

<br>

<div class="alert success-bg centered">

Solve this <strong class="danger">concurrency problem</strong><br>
using <strong class="warning">semaphores</strong>.

</div>

---

# Semaphores: <span class="gold">Lock</span>

<div class="columns">

<div>

To use a <strong class="special">semaphore</strong> as a <strong
class="warning">lock</strong>:

- Initialize the <strong class="special">semaphore</strong> to

    <strong> __________________________</strong>.

    <br>

- Perform a <strong class="success"> _________________</strong>
  to *acquire* the <strong class="warning">lock</strong>.

    <br>

- Perform a <strong class="success"> _________________</strong>
  to *release* the <strong class="warning">lock</strong>.

</div>

<div>

```c
// Initialize lock




// Perform Lock







```

</div>

</div>

---

# Semaphores: <span class="gold">Condition Variable</span>

<div class="columns">

<div>

To use a <strong class="special">semaphore</strong> as a <strong
class="caution">condition variable</strong>:

- Initialize the <strong class="special">semaphore</strong> to

    <strong> __________________________</strong>.

    <br>

- Perform a <strong class="success"> _________________</strong>
  to *wait* on the <strong class="caution">condition variable</strong>.

    <br>

- Perform a <strong class="success"> _________________</strong>
  to *signal* the <strong class="caution">condition variable</strong>.

</div>

<div>

```c
// Initialize cond var



// Thread 1: Wait



// Thread 2: Signal




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

# Project 02: <span class="gold">Pub / Sub</span>

<div class="slide-centered">

<img src="static/img/project02-client.svg">

</div>

---

# Project 02: <span class="gold">Chat Application</span>

<div class="slide-centered">

<img src="static/img/project02-chat-application.svg" height="600px">

</div>

---

# Project 02: <span class="gold">Pub / Sub</span> (<i class="muted">Pusher</i>)

<div class="columns-2-1">

<div>

<strong class="success">Pusher</strong>():


</div>

<div class="centered">

<img src="static/img/project02-client-simplified.svg">

</div>

</div>

---

# Project 02: <span class="gold">Pub / Sub</span> (<i class="muted">Puller</i>)

<div class="columns-2-1">

<div>

<strong class="danger">Puller</strong>():

</div>

<div class="centered">

<img src="static/img/project02-client-simplified.svg">

</div>

</div>

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
