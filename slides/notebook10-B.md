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

# Reading 04 vs Reading 05

---

# Condition Variable: <span class="gold">Waiting</span>

> <strong class="primary">cond_wait</strong>(&cond, &lock);

<br>

1. <strong> ____________________________________________________________</strong>

    <br>

2. <strong> ____________________________________________________________</strong>

    <br>
    ...
    <br>
    <br>

3. <strong> ____________________________________________________________</strong>

    <br>

4. <strong> ____________________________________________________________</strong>

---

# Locks: <span class="gold">Evaluation</span>

To evaluate a <strong class="warning">lock</strong> implementation, we need to
consider the following three <strong class="special">metrics</strong>:

<br>

1. <strong class="caution"> _______________________________________</strong>

    Does it actually provide <strong class="warning">mutual exclusion</strong>?

    <br>

2. <strong class="info">    _______________________________________</strong>

    Does it give each <strong class="primary">thread</strong> a fair shot at
    acquiring the <strong class="warning">lock</strong>?

    <br>

3. <strong class="success"> _______________________________________</strong>

    How much overhead is added by using the <strong
    class="warning">lock</strong>?

---

# Locks: <span class="gold">Disabling Interrupts</span>

One way to implement <strong class="warning">locks</strong> is to simply <strong class="danger">disable
interrupts</strong>:

<div class="columns">

<div>

```python
class Mutex:
    def Lock(self):
        DisableInterrupts()

    def Unlock(self):
        EnableInterrupts()
```

</div>


<div class="margin-top-0-5">

<strong class="danger">Problems</strong>

1. <strong class="caution">Correctness</strong>

    <br><strong> __________________________</strong>

2. <strong class="info">Fairness</strong>

    <br><strong> __________________________</strong>

3. <strong class="success">Performance</strong>

    <br><strong> __________________________</strong>

</div>

</div>

---

# Locks: <span class="gold">Implementation</span> (<i class="muted">Spin Lock</i>)

A better way is to implement a <strong class="warning">spin lock</strong>:

<div class="columns-2-1">

<div>

```python
class Mutex:
    #
    # _________________________________________
    flag: int = 0

    def Lock(self):
        #
        # _____________________________________
        while self.flag == 1: pass
        self.flag = 1

    def Unlock(self):
        #
        # _____________________________________
        self.flag = 0
```

</div>

<div class="margin-top-0-5">

<strong class="danger">Problems</strong>

1. <strong class="caution">Correctness</strong>

    <br><strong> __________________________</strong>

2. <strong class="success">Performance</strong>

    <br><strong> __________________________</strong>

</div>

</div>

---

# Locks: <span class="gold">Test and Set</span>

To effectively implement a <strong class="warning">lock</strong>, we need
special <strong class="info">hardware instructions</strong> that provide
<strong class="special">atomic exchanges</strong>:

```python
def TestAndSet(old_ptr: int*, new_value: int):
                            #
    old_value = *old_ptr    # _______________________________________________
                            #
    *old_ptr  = new_value   # _______________________________________________
                            #
    return old_value        # _______________________________________________
```

<br>

<div class="alert info-bg centered">

The above three lines all happen in one instruction<br>

(<strong class="special">_____________________________________</strong>)

</div>

---

# Locks: <span class="gold">Test and Set</span> (<i class="muted">Spin Lock</i>)

With the <strong class="info">TestAndSet</strong> instruction, we can implement
a better <strong class="warning">spin lock</strong>.

<div class="columns-2-1">

<div>

```python
class Mutex:
    # 0: available, 1: unavailable
    flag: int = 0

    def Lock(self):
        #
        # _____________________________________
        while TestAndSet(self.flag, 1) == 1:
            pass # Spin until lock is available

    def Unlock(self):
        # Clear lock
        self.flag = 0
```

</div>

<div class="margin-top-0-5">

<strong class="danger">Problems</strong>

1. <strong class="success">Performance</strong>

    <br><strong> __________________________</strong>

</div>

</div>

---

# Locks: <span class="gold">Yielding</span> (<i class="muted">Spin Lock</i>)

One way to reduce the cost of <strong class="danger">busy waiting</strong> is
to simply <strong class="caution">yield</strong> as we spin:

```python
class Mutex:
    flag: int = 0                               # 0: available, 1: unavailable

    def Lock(self):
        while TestAndSet(self.flag, 1) == 1:    # Test and Set lock atomically
            yield() #
                    # ________________________________________________________

    def Unlock(self):
        self.flag = 0                           # Clear lock
```

---

# Example: <span class="gold">Slackline</span> (<i class="muted">Locks, CVs</i>)

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

Solve this <strong class="danger">concurrency problem</strong> using<br>
<strong class="warning">locks</strong> and <strong class="caution">condition
variables</strong>.

</div>

---

<!-- _class: lead -->

# Semaphores

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

Solve this <strong class="danger">concurrency problem</strong> using<br>
<strong class="warning">semaphores</strong>.

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

# Semaphores: <span class="gold">Producer / Consumer</span>

Let's [modify] our previous `C` queue to utilize <strong
class="special">semaphores</strong> instead of POSIX <strong
class="warning">locks</strong> and <strong class="caution">condition
variables</strong>:

<br>

- We want to check condition <strong class="special">semaphores</strong>
  <strong> ______________________</strong> *acquiring* lock
  <strong class="special">semaphore</strong>.

    <br>

- Need to release lock <strong class="special">semaphore</strong>
  <strong> _____________________________</strong> *signaling* conditions.

[modify]: https://github.com/nd-cse-30341-fa26/examples/tree/master/lecture11

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
