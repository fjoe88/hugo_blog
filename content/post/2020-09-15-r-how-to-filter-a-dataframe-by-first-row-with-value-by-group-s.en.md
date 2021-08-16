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

Here's a problem that I encountered while doing data analysis using R: my data consists of a few id columns, by combining these id columns I should in theory receive one unique observation (row) per each unique combination (group) - in reality I end up having multiple rows per group, some rows are duplications, and some simply are rows with no data. In order to clean this datasetm, I want to reduce this dataframe so that it contains only **the first row per group that is not empty in a specific data column**.

Here is an example:

```R

df = data.frame(
  id1 = c("a", "a", "b", "c", "b", "b", "d", "d", "b", "c"),
  id2 = c(1,2,1,1,2,1,1,1,2,1),
  data = c("foo", "bar", "foo", NA, "bar", "bar", NA, NA, NA, "foo")
)

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

```

What I would like is to reduce this dataframe to:

```R
# group d-1 contains only NAs
#    id1 id2 data
# 1    a   1  foo
# 2    a   2  bar
# 3    b   1  foo
# 4    b   2  bar
# 5    c   1  foo
```

My attempt for a made-ready solution online didnt end up with great successes, and I decide to take up the challange.

To start off I need to have a simple function that returns boolean results of if the input object is NULL, NA or simply empty strings or multiple spaces - and I need the function to be **vectorized**.

And NULL really made things more complicated as is almost always the case.

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

#[1] TRUE
contain_value("not empty")

#[1] FALSE
contain_value(NULL)

 #  <NA>  apple banana               
 # FALSE   TRUE   TRUE  FALSE   TRUE
contain_value(c(NA, "apple", "banana", "", "  "))
```

Now I can go ahead and tackle my problem using `dplyr` pipes:

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

Interestingly with R being Functional Programming oriented, function pipes in the form of `slice(first(which(contain_value(data))))` is quite intuitive and can be interperted as such: 

***slice** the **first** occurence(row) **which** **contains value** in the '**data**' column.* 

:)

Now, another approach would be to use data.table package, in a similar way and also utilizing `contain_value` function.

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

I am also looking to create a solution where the data column is not restricted to a single column but to allow multiples.


