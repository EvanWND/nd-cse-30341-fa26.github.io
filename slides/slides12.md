---
title: "Slides 12: Concurrency Bugs"
description: "Concurrency Bugs"
author: Peter Bui
keywords: lecture,osp,threads,concurrency bugs,race condition,deadlock
url: https://pnutz.h4x0r.space/courses/cse.30341.fa26/slides12.html
theme: domer-slides
---

<!-- _class: lead -->

# CSE 30341

## Concurrency Bugs

---

# Questions

<div class="font-large">

1. What are some common <strong class="danger">concurrency bugs</strong>?

2. What are some ways to <strong class="success">prevent</strong> or <strong
   class="success">avoid</strong> such bugs?

</div>

---

# Bug: <span class="gold">Atomicity Violation</span>

An <strong class="danger">atomicity violation</strong> occurs when we have a
code region that assumes its execution is <strong
class="special">atomic</strong>, but it is not actually enforced.

<div class="columns">

<div>

```python
def thread_1():
    if image:
        copy(image)
```

</div>

<div>

```python
def thread_2():
    erase(image)
```

</div>

</div>

<br>

<div class="alert info-bg centered">

Solve <strong class="danger">atomicity violation</strong> by <strong
class="warning">locking</strong> resource.

</div>

---

# Bug: <span class="gold">Atomicity Violation</span> (<i class="muted">Examples</i>)

<table class="bordered">
<thead>
    <th class="success-bg">Thread 1</th>
    <th class="success-bg">Thread 2</th>
</thead>
<tbody>
<tr>
<td class="caution-bg" width="600px">

```python
if buf_index + len < BUFSIZ:
    memcpy(buf[buf_index], log, len)
```

</td>
<td class="caution-bg" width="600px">

```python
buf_index += len
```

</td>
</tr>
</tbody>
</table>

<table class="bordered">
<thead>
    <th class="success-bg">Thread 1</th>
    <th class="success-bg">Thread 2</th>
</thead>
<tbody>
<tr>
<td class="caution-bg" width="600px">

```python
lock()
y = calculate()
unlock()

lock()
if (y == 0): y = 1  # Avoid division by zero
unlock()
```

</td>
<td class="caution-bg" width="600px">

```python
lock()
a = x / y
unlock()
```

</td>
</tr>
</tbody>
</table>

---

# Bug: <span class="gold">Order Violation</span>

An <strong class="danger">order violation</strong> occurs when we desire a
certain <strong class="special">sequence</strong> of operations, but it is not
actually enforced.

<div class="columns">

<div>

```python
def thread_1():
    draw(image)
```

</div>

<div>

```python
def thread_2():
    copy(image)
```

</div>

</div>

<br>

<div class="alert info-bg centered">

Solve <strong class="danger">order violation</strong> with <strong
class="caution">condition variables</strong> (and <strong
class="warning">locks</strong>).

</div>

---

# Bug: <span class="gold">Order Violation</span> (<i class="muted">Examples</i>)

<table class="bordered">
<thead>
    <th class="success-bg">Thread 1</th>
    <th class="success-bg">Thread 2</th>
</thead>
<tbody>
<tr>
<td class="caution-bg" width="600px">

```python
mq.incoming = queue_create()
```

</td>
<td class="caution-bg" width="600px">

```python
if mq.incoming:
    data = queue_pop(mq.incoming)
```

</td>
</tr>
</tbody>
</table>

<table class="bordered">
<thead>
    <th class="success-bg">Thread 1</th>
    <th class="success-bg">Thread 2</th>
</thead>
<tbody>
<tr>
<td class="caution-bg" width="600px">

```python
while True:
    queue_push(mq, request)
```

</td>
<td class="caution-bg" width="600px">

```python
queue_delete(mq.incoming)
```

</td>
</tr>
</tbody>
</table>

---

# Bug: <span class="gold">Starvation</span>

<div class="columns">

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

<div>

<div class="centered">

<strong class="danger">Starvation</strong> occurs when a <strong
class="primary">thread</strong> is prevented from ever accessing a resource.

</div>

```c
size_t Readers    = 0
sem_t  WriterLock = 1
sem_t  ReaderLock = 1

Writer():
    sem_wait(&WriterLock)
    do_write()
    sem_post(&WriterLock)
```
</div>

</div>


---

# Bug: <span class="gold">Deadlock</span>

A <strong class="danger">deadlock</strong> occurs when each <strong
class="primary">thread</strong> is waiting for another to give up a resource
and none can run.  Usually this is because there is a <strong
class="warning">cycle</strong> in the graph of dependencies.

<br>

<table class="bordered">
<thead>
    <th class="success-bg">Thread 1</th>
    <th class="success-bg">Thread 2</th>
</thead>
<tbody>
<tr>
<td class="caution-bg" width="600px">

```python
Lock(Mask)
Lock(Sanitizer)
```

</td>
<td class="caution-bg" width="600px">

```python
Lock(Sanitizer)
Lock(Mask)
```

</td>
</tr>
</tbody>
</table>

---

# Bug: <span class="gold">Livelock</span>

<strong class="danger">Livelock</strong> occurs when multiple <strong
class="primary">threads</strong> are actively attempting to acquire resources,
but <strong class="warning">cannot make progress</strong>.

<br>

<table class="bordered">
<thead>
    <th class="success-bg">Thread 1</th>
    <th class="success-bg">Thread 2</th>
</thead>
<tbody>
<tr>
<td class="caution-bg" width="600px">

```python
while True:
    Lock(Mask)
    # Check if other resource is already locked
    if Locked(Sanitizer):
        Unlock(Mask)
        continue
    Lock(Sanitizer)
    ...
    Unlock(Sanitizer)
    Unlock(Mask)
```

</td>
<td class="caution-bg" width="600px">

```python
while True:
    Lock(Sanitizer)
    # Check if other resource is already locked
    if Locked(Mask):
        Unlock(Sanitizer)
        continue
    Lock(Mask)
    ...
    Unlock(Mask)
    Unlock(Sanitizer)
```

</td>
</tr>
</tbody>
</table>

---

# Bug: <span class="gold">Dining Philosophers</span>

<div class="columns">

<div>

There are **five philosophers** eating dinner...

<img src="https://spin.atomicobject.com/wp-content/uploads/dining-philosophers.jpg" class="framed float-right" width="225px">

- There are only **five forks**.

- To eat, each person needs a **left** and **right fork**.

<div class="alert warning-bg centered">

Need to ensure no <strong class="danger">deadlock</strong> and no one <strong
class="danger">starves</strong>.

</div>

</div>

<div>

```python
def philosopher(p):
    while True:
        think(p)
        get_forks(p)    # Deadlock!!!
        eat(p)
        put_forks(p)

def get_forks(p):
    sem_wait(forks[left(p)])
    sem_wait(forks[right(p)])

def put_forks(p):
    sem_post(forks[left(p)])
    sem_post(forks[right(p)])
```

</div>

</div>

---

# Bug: <span class="gold">Conditions</span>

<table class="bordered">
<tbody>
<tr>
<td class="special-bg" width="600px">
<b>Mutual Execution</b>

Threads claim exclusive control of resources.

<br>
</td>
<td class="caution-bg" width="600px">
<b>No Pre-emption</b>

Resources cannot be forcibly removed from threads holding them.
</td>
</tr>
<tr>
<td class="warning-bg">
<b>Hold-and-Wait</b>

Threads hold resources while waiting for additional resources.

<br>
</td>
<td class="danger-bg">
<b>Circular Wait</b>

There exists a circular chain of threads such that each thread holds one or
more resources needed by another.
</td>
</tr>
</tbody>
</table>

---

# Bug: <span class="gold">Prevention and Avoidance</span>

<table class="bordered">
<tbody>
<tr>
<td class="special-bg" width="600px">
<b>Mutual Execution</b>

Don't use locks (*don't share resources*)!

<br>
</td>
<td class="caution-bg" width="600px">
<b>No Pre-emption</b>

Force thread to give up lock and wait until it can re-acquire lock.

</td>
</tr>
<tr>
<td class="warning-bg">
<b>Hold-and-Wait</b>

Give up lock if can't get the next one and try again.

</td>
<td class="danger-bg">
<b>Circular Wait</b>

Provide ordering on how to acquire locks.
</td>
</tr>
</tbody>
</table>

<br>

<div class="alert success-bg centered">

To avoid <strong class="danger">deadlock</strong>, we can try to utilize
<strong class="success">smarter scheduling</strong> or simply have a mechanism
for <strong class="caution">detecting</strong> it and <strong
class="caution">recovering</strong>.

</div>
