# oboe

oboe is an implementation of a strong version of the "off-by-one" programming language described by Randall Munroe in [xkcd #3602](https://xkcd.com/3062/):

![xkcd #3602](https://github.com/user-attachments/assets/5f0ebe84-caf8-43bb-a54a-3a2754f34a03)

> "_Any time an integer is stored or read, its value is adjusted upward or downward by a random amount between 40 and 50._"

Inspired by [Shriram Krishnamurthi's "off-by-one" implementation](https://github.com/shriram/xkcd-3062).

## Design

Shriram raises and addresses the following [design decisions](https://github.com/shriram/xkcd-3062?tab=readme-ov-file#design-decisions) in his implementation that are up for interpretation in the comic:

> _Is the 40–50 interval open, closed, clopen, …._
>
> _Whether only integer constants or integer-bound variables are also included._
>
> _Related to the above, whether reading a variable also changes it._

Shriram chose well-reasoned, pragmatic responses to these questions. This implementation does the opposite.
oboe chooses the strongest interpretation of the comic's description. So, it implements the language in the most chaotic way possible:

- oboe chooses a closed interval [40, 50].
- oboe handles integer constants as well as integer-bound variables.
- oboe adjusts values on write _and_ read.

It is impossible and infurating.
