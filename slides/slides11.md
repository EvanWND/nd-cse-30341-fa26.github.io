---
title: "Slides 11: Semaphores"
description: "Semaphores"
author: Peter Bui
keywords: lecture,osp,threads,semaphores,producer consumer
url: https://pnutz.h4x0r.space/courses/cse.30341.fa26/slides11.html
theme: domer-slides
---

<!-- _class: lead -->

# CSE 30341

## Semaphores

---

# Questions

<div class="font-large">

1. What is a <strong class="special">semaphore</strong>?

2. What <strong class="success">operations</strong> does a <strong
   class="special">semaphore</strong> provide?

3. How do we use use <strong class="special">semaphores</strong> to synchronize
   <strong class="primary">threads</strong>?

</div>

---

# Semaphores: <span class="gold">Overview</span>

A <strong class="special">semaphore</strong> is a synchronization primitive
that consists of an <strong class="caution">integer</strong> that we can
manipulate with two <strong class="success">operations</strong>:

<br>

<div class="columns">

<div>

```python
def sem_wait(s):
    s.value--
    if s.value < 0:
        thread_wait()
```

</div>

<div>

```python
def sem_post(s):
    s.value++
    if threads_waiting():
        threads_wakeup_next()
```

</div>

</div>

---

# Semaphores: <span class="gold">Lock</span>

<div class="columns">

<div>

To use a <strong class="special">semaphore</strong> as a <strong
class="warning">lock</strong>:

- Initialize the <strong class="special">semaphore</strong> to `1`.

- Perform a <strong class="success">Wait</strong> to *acquire* the <strong
  class="warning">lock</strong>.

- Perform a <strong class="success">Post</strong> to *release* the <strong
  class="warning">lock</strong>.

</div>

<div>

```c
// Initialize lock
sem_t m;
sem_init(&m, 0, 1);


// Perform Lock
sem_wait(&m);
// Do critical section
sem_post(&m);
```

</div>

</div>

---

# Semaphores: <span class="gold">Condition Variable</span>

<div class="columns">

<div>

To use a <strong class="special">semaphore</strong> as a <strong
class="caution">condition variable</strong>:

- Initialize the <strong class="special">semaphore</strong> to `0`.

- Perform a <strong class="success">Wait</strong> to *wait* on the <strong
  class="caution">condition variable</strong>.

- Perform a <strong class="success">Post</strong> to *signal* the <strong
  class="caution">condition variable</strong>.

</div>

<div>

```c
// Initialize cond var
sem_t cv;
sem_init(&cv, 0, 0);


// Thread 1: Wait
sem_wait(&cv);
do_the_thing();


// Thread 2: Signal
do_another_thing();
sem_post(&cv);
```

</div>

</div>

---

# Semaphores: <span class="gold">Producer / Consumer</span>

Let's [modify] our previous `C` queue to utilize <strong
class="special">semaphores</strong> instead of POSIX <strong
class="warning">locks</strong> and <strong class="caution">condition
variables</strong>:

- We want to check condition <strong class="special">semaphores</strong> before
  acquiring lock <strong class="special">semaphore</strong>.

- Need to release lock <strong class="special">semaphore</strong> before
  signaling conditions.

[modify]: https://github.com/nd-cse-30341-fa26/examples/tree/master/lecture11

---

# Semaphores: <span class="gold">Reader-Writer Locks</span>

With <strong class="special">semaphores</strong>, we can create interesting
synchronization objects such as <strong class="danger">reader-writer
locks</strong>:

- Once <strong class="success">readers</strong> acquire the <strong
  class="warning">writelock</strong>, as many <strong
  class="success">readers</strong> as possible can read the data.

- Once a <strong class="danger">writer</strong> acquires the <strong
  class="warning">writelock</strong>, no one else can access the data.

- Unfortunately, this can add <strong class="caution">overhead</strong> and is
  prone to <strong class="danger">starvation</strong>.

---

# Semaphores: <span class="gold">Reader Preference</span>

<div class="columns">

<div>

```c
size_t Readers    = 0
sem_t  WriterLock = 1
sem_t  ReaderLock = 1

Writer():
    sem_wait(&WriterLock)
    do_write()
    sem_post(&WriterLock)
```

- <strong class="success">Pro</strong>: Allows multiple readers
- <strong class="danger">Con</strong>: Writer may starve

</div>

<div>

```c
Reader():
    sem_wait(&ReaderLock)
    if Readers == 0:
        sem_wait(WriterLock)
    Readers++
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

# Semaphores: <span class="gold">Fair</span>

<div class="columns">

<div>

```c
size_t Readers      = 0
sem_t  WriterLock   = 1
sem_t  ReaderLock   = 1
sem_t  ServiceQueue = 1     //

Writer():
    sem_wait(&ServiceQueue) //
    sem_wait(&WriterLock)
    sem_post(&ServiceQueue) //
    do_write()
    sem_post(&WriterLock)
```

</div>

<div>

```c
Reader():
    sem_wait(&ServiceQueue) //
    sem_wait(&ReaderLock)
    if Readers == 0:
        sem_wait(WriterLock)
    Readers++
    sem_post(&ServiceQueue) //
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

# Semaphores: <span class="gold">Fair</span> (<i class="muted">Analysis</i>)

<div class="columns">

<div>

Suppose <strong class="danger">Writer</strong> *acquires* <strong
class="special">ServiceQueue</strong> and <strong
class="warning">WriterLock</strong> and then *releases* <strong
class="special">ServiceQueue</strong>:

- A new <strong class="danger">Writer</strong> will *acquire* <strong
  class="special">ServiceQueue</strong> and then *wait* on <strong
  class="warning">WriterLock</strong>.

- A new <strong class="success">Reader</strong> will *acquire* <strong
  class="special">ServiceQueue</strong> and then *wait* on <strong
  class="warning">WriterLock</strong>.

</div>

<div>

Suppose <strong class="success">Reader</strong> *acquires* <strong
class="special">ServiceQueue</strong>, <strong
class="warning">ReaderLock</strong>, and <strong
class="warning">WriterLock</strong> and then
*releases* <strong class="special">ServiceQueue</strong>:

- A new <strong class="danger">Writer</strong> will *acquire* <strong
  class="special">ServiceQueue</strong> and then *wait* on <strong
  class="warning">WriterLock</strong>.

- A new <strong class="success">Reader</strong> will *acquire* <strong
  class="special">ServiceQueue</strong> and then *wait* on <strong
  class="warning">ReaderLock</strong>.

</div>

---

# Semaphores: <span class="gold">Summary</span>

<strong class="special">Semaphores</strong> are another useful and flexible
synchronization primitive:

- Good when you need a <strong class="danger">barrier</strong> or want to have
  <strong class="danger">bounded</strong> access to a resource.

- Unlike <strong class="warning">locks</strong> and <strong
  class="caution">condition variables</strong>, there is no notion of <strong
  class="primary">ownership</strong>.

- Can avoid using <strong class="warning">locks</strong> and <strong
  class="caution">condition variables</strong> if desired.
