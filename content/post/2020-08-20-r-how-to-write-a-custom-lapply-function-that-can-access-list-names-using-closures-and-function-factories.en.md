---
title: '[R] How to write a custom lapply function that can access
  list names, using closures and function factories'
author: zhoufang
date: '2020-08-20'
slug: r-how-to-write-a-custom-lapply-function-that-can-access-list-names-using-closures-and-function-factories
categories:
  - R
tags:
  - R
description: ~
featured_image: ~
---

When using R, one of my favorite as well as most frequently used base function in is `lapply`, which allows one to apply a function over an iterable such as a`list` or a `vector`, and return a `list` of the same length (hence the `l` in `lapply`).

Example:

```{r}
num <- list(0, 1, 2, 3)
add_one <- function(x) x+1

#returns a new list same length as num but with each number element increased by one
num_add_one <- lapply(num, add_one)
```

Another variant of the `apply` family - `sapply`, works similarly to `lapply` except that the returned result will be simplified, if possible.

```{r}
#return a numeric vector instead of a list
num_add_one_simp <- sapply(num, add_one)
```

I see both `lapply` and `sapply` as vectorized version of writing up a for loop to iterate through an iterable such as a list or a vector, then return results iteratively to an empty list - which is an approach that is not encouraged for many reasons such as performance or readability. In Python this concept translates to language features such as `list comprehensions` that is very similar to `lapply`.

One of my frequent task is to also have access to the list's name attribute inside the function call while using `lapply`, so that I can build custom conditionals inside my function that can be dependent upon the name of each item from the list. Unfortunately, base R version of `lapply` does not allow such scenario to happen.

```{r}
names(num) <- c("a", "b", "c", "d")

#returns NULL
list_of_names <- lapply(num, function(x) names(x))
```

While seeking helps on this issue, I encountered this stackoverflow question - ["access-and-preserve-list-names-in-lapply-function"](https://stackoverflow.com/questions/9469504/access-and-preserve-list-names-in-lapply-function) and found other people having similar issues, but none provided a solution to the actually problem therefore I decide to just write a custom `lapply` version that does just that, using functional programming features of closure and function factories.

```{r}
lapply_preserve_names <- function(list, fun){
  lapply(seq_along(list), function(i){
    obj <- list[i]
    names(obj) <- names(list)[i]

    #instead of calling lapply on each item, calling on a length of 1 list with names attribute preserved
    fun(obj)
  })
}
```

Now, instead of using `lapply`, simply use `lapply_preserve_names`, one caveat being that the first argument of function call becomes a list of length 1, and double bracket indexing is required to access the item itself , e.g. "x[[1]]"

```{r}
get_names <- lapply_preserve_names(num, function(x) names(x))
```

Also notice that there can be work-around such as below example, however it requires `lapply` first argument not to be the iterable itself, plus one need to use list indexing by name which is not as straight forward as the solution before.

```{r}
#use list index by name to access item itself while preserve names
foo <- lapply(names(num), function(x) num[x])
```
