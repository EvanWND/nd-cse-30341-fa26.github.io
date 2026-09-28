---
title: "Notebook 10: Condition Variables"
description: "Condition Variables"
author: Peter Bui
keywords: notebook,osp,threads,condition variables,concurrent data structure,producer consumer
url: https://pnutz.h4x0r.space/courses/cse.30341.fa26/notebook10.html
theme: domer-slides
---

<!-- _class: lead -->

# CSE 30341

## Condition Variables

---

# Questions

<div class="font-large">

1. Why do we need <strong class="caution">condition variables</strong>?

2. How do we use <strong class="caution">condition variables</strong> to build
   <strong class="primary">concurrent data structures</strong>?

</div>

---

# Project 02: <span class="gold">Pub / Sub</span>

<div class="slide-centered">

<img src="static/img/project02-pubsub-blank.svg">

</div>

---

# Concurrent DS: <span class="gold">Producer / Consumer</span>

<div class="slide-centered">

<img src="static/img/slides10-producer-consumer.svg" width="400px">

</div>

---

# Concurrent DS: <span class="gold">Monitor</span>

<div class="slide-centered">

<img src="static/img/slides10-monitor.svg" width="400px">

</div>


---

# Concurrent DS: <span class="gold">Queue</span>

Let's build a `C` version of this problem that utilizes a fixed-sized <strong
class="primary">array</strong> as the underlying buffer between the <strong
class="success">producer</strong> and <strong
class="danger">consumers</strong>:

<br>

- [Queue 0]: <strong> ___________________________________________________</strong>

    <br>

- [Queue 1]: <strong> ___________________________________________________</strong>

    <br>

- [Queue 2]: <strong> ___________________________________________________</strong>

    <br>

- [Queue 3]: <strong> ___________________________________________________</strong>

[queue.c]: https://github.com/nd-cse-30341-fa26/examples/tree/master/lecture10
[Queue 0]: https://github.com/nd-cse-30341-fa26/examples/tree/master/lecture10/queue0.c
[Queue 1]: https://github.com/nd-cse-30341-fa26/examples/tree/master/lecture10/queue1.c
[Queue 2]: https://github.com/nd-cse-30341-fa26/examples/tree/master/lecture10/queue2.c
[Queue 3]: https://github.com/nd-cse-30341-fa26/examples/tree/master/lecture10/queue3.c

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

<div class="columns-2-1">

<div>

```python
class Mutex:
    # 0: available, 1: unavailable
    flag: int = 0

    def Lock(self):
        # Test and Set lock atomically
        while TestAndSet(self.flag, 1) == 1:
            #
            # ______________________________
            yield()

    def Unlock(self):
        # Clear lock
        self.flag = 0
```

</div>

<div class="margin-top-0-5">

<strong class="danger">Problems</strong>

1. <strong class="info">Fairness</strong>

    <br><strong> __________________________</strong>

2. <strong class="success">Performance</strong>

    <br><strong> __________________________</strong>

</div>

</div>

---

# Example: <span class="gold">Slackline</span>

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

# Example: <span class="gold">Slackline</span> (<i class="muted">Locks, CVs</i>)
