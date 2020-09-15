---
title: '[R] How to filter a dataframe by first row with value by group(s)'
author: zhoufang
date: '2020-09-15'
slug: r-how-to-filter-a-dataframe-by-first-row-with-value-by-group-s
categories:
  - R
tags:
  - R
description: ~
featured_image: ~
---

While doing data analysis using R I encountered a problem where once grouped by some id columns, some group still contain multiple columns, and what I want is to reduce it to only the first row per group that is not empty in a specific data column.

To put it into an example:

```R
#    id1 id2 data
# 1    a   1  foo
# 2    a   2  bar
# 3    b   1  foo
# 4    c   1 <NA>
# 5    b   2  bar
# 6    b   1  bar
# 7    d   1 <NA>
# 8    d   1 <NA>
# 9    b   2 <NA>
# 10   c   1  foo

df = data.frame(
  id1 = c("a", "a", "b", "c", "b", "b", "d", "d", "b", "c"),
  id2 = c(1,2,1,1,2,1,1,1,2,1),
  data = c("foo", "bar", "foo", NA, "bar", "bar", NA, NA, NA, "foo")
)
```

And what I'm shooting for is to reduce this dataframe down to:

```R
# group d-1 d-2 contains only NAs
#    id1 id2 data
# 1    a   1  foo
# 2    a   2  bar
# 3    b   1  foo
# 4    b   2  bar
# 5    c   1  foo
```

Online searches didnt really result in great successes thus I decide to write up a custom solution, to start of I need to have a simple function that returns boolean results of if the input object is NULL, NA or simply empty strings or multiple spaces - and I need the function to be vectorized.

And NULL really made things more complicated.

```R
#contain_value(NULL) == FALSE

contain_value <- function(x){

  doesnt_contain_value <- function(x){
    c1 <- is.null(x)
    c2 <- is.na(x)
    c3 <- grepl("^[[:space:]]?$", x)

    return(any(c(c1, c2, c3))) #is.na(NULL) == logical(0)
  }

  #length(NULL) == 0
  if (length(x)<=1) {
    return(!doesnt_contain_value(x))
  }

  sapply(x, function(y){
    !doesnt_contain_value(y)
    })
}
```

Now I can tackle the problem using dplyr pipes:

```R
library(magrittr)
library(dplyr)

df %>% group_by(id1, id2) %>% slice(first(which(contain_value(data))))

# A tibble: 5 x 3
# Groups:   id1, id2 [5]
#   id1     id2 data 
#   <chr> <dbl> <chr>
# 1 a         1 foo  
# 2 a         2 bar  
# 3 b         1 foo  
# 4 b         2 bar  
# 5 c         1 foo 
```

Wallah!

Notice that with R being functional programming oriented, function pipes in the form of `slice(first(which(contain_value(data))))` is quite intuitive and can be interperted as - give(slice) the first occurence of which that contains value in `data` column. :)

Now, another approach using data.table package.

```R
library(data.table)

dt <- as.data.table(df)

dt[, .SD[first(which(contain_value(data)))], by=c('id1', 'id2')]

#    id1 id2 data
# 1:   a   1  foo
# 2:   a   2  bar
# 3:   b   1  foo
# 4:   c   1  foo
# 5:   b   2  bar
```


