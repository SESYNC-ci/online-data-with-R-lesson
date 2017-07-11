---
---

## Data structures

The built-in structures for holding multiple values are:

- Tuple
- List
- Set
- Dictionary

===

## Tuple

The simplest kind of sequence, a tuple is declared with comma-separated values inside `()` as we have already seen, or inside nothing at all. Note that to declare a one-tuple, a trailing "," is required.


~~~python
>>> t = 'cat',
>>> type(t)
<type 'tuple'>

~~~
{:.output}



===

## List

The more common kind of sequence in Python is the list, which is declared with comma-separated values inside `[]`. Unlike a tuple, a list is mutable.


~~~python
>>> l = [3.14, 'xyz', t]
>>> type(l)
<type 'list'>

~~~
{:.output}



===

## Subsetting Tuples and Lists

Subsetting elements from a tuple or list is performed with square brackets in both cases, and selects elements using their integer position starting from zero---their "index".


~~~python
>>> l[0]
3.14

~~~
{:.output}



===

Negative indices are allowed, and refer to the reverse ordering: -1 is the last item in the list, -2 the second-to-last item, and so on.


~~~python
>>> l[-1]
('cat',)

~~~
{:.output}



===

The syntax `l[i:j]` selects a sub-list starting with the element at index
`i` and ending with the element at index `j - 1`.


~~~python
>>> l[0:2]
[3.14, 'xyz']

~~~
{:.output}



A blank space before or after the ":" indicates the start or end of the list,
respectively. For example, the previous example could have been written 
`l[:2]`.

===

A potentially useful trick to remember the list subsetting rules in Python is
to picture the indices as "dividers" between list elements.

```
 0      1       2          3 
 | 3.14 | 'xyz' | ('cat',) |
-3     -2      -1
```
{:.input}

Positive indices are written at the top and negative indices at the bottom. 
`l[i]` returns the element to the right of `i` whereas `l[i:j]` returns
elements between `i` and `j`.

===

## Exercise 2

Create a Python list containing zero as a float, the integer 2, and a tuple of three separate characters. Now, assume you did not know the length of the list and extract the last two elements.

===

## Set

The third and last "sequence" data structure is a set, used mainly for quick access to set operations like "union" and "difference". Declare a set with comma-separated values inside `{}` or by casting another sequence with `set()`.


~~~python
>>> s = set(l)

~~~
{:.output}




~~~python
>>> s.difference({3.14})
set([('cat',), 'xyz'])

~~~
{:.output}



Python is a principled language: a set is technically unordered, so its elements do not have an index. You cannot subset a set using `[]`.

===

## Dictionary

Lists are useful when you need to access elements by their position in a
sequence. In contrast, a dictionary is needed to find values based on arbitrary identifiers.

Construct a dictionary with comma-separated `key:value` pairs in `{}`.


~~~python
toons = {'Snowy':'dog', 'Garfield':'cat', 'Bugs':'bunny'}
~~~
{:.text-document title="worksheet.py"}



~~~python
>>> type(toons)
<type 'dict'>

~~~
{:.output}



===

Individual values are accessed using square brackets, as for lists, but the key must be used rather than an index.


~~~python
>>> toons['Bugs']
'bunny'

~~~
{:.output}



===

To add a single new element to the dictionary, define a new `key:value` pair by assigning a value to a novel key in the dictionary.


~~~python
>>> toons['Goofy'] = 'dog'
>>> toons
{'Garfield': 'cat', 'Goofy': 'dog', 'Bugs': 'bunny', 'Snowy': 'dog'}

~~~
{:.output}



Dictionary keys are unique. Assigning a value to an existing key overwrites its previous value.

===

## Exercise 3

Based on what we have learned so far about lists and dictionaries, think up a data structure suitable for an address book. Using what you come up with, store the contact information (i.e. the name and email address) of three or four (hypothetical) persons as a variable `addr`.
