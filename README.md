# Shades

Get a new perspective on your data. In-memory [OLAP cubing](http://en.wikipedia.org/wiki/OLAP_cube), histograms, and more for Ruby.

![](https://dl.dropboxusercontent.com/u/1133314/i/shades.gif)

## As a command line utility for OLAP cubing

The ```shades``` utility will accept whitespace-delimited data, one event per line, preceeded by two commented lines describing the dimensions and data within.

```
# dimensions: timestamp transactionid customer item
# measures: quantity amount
1371958271 1 jack golfclubs  3 75.00
1371937693 1 jack gin        2 40.00
1371979661 2 jane jar        6  6.00
```

Each line will be parsed as a ```Shades::Event``` according to the metadata given in the first two lines. So the line

```
1371937693 1 jack gin        2 40.00
```

Will create a ```Shades::Event``` of the form:

```
dimensions: 
  timestamp      = 1371937693 
  transactionid  = 1
  customer       = jack
  item           = gin
measures:
  quantity       = 2
  amount         = 40.00
```

Then we can perform simple aggregations like so. This one finds the total amount each customer has spent

```> cat transactions.txt | shades "sum(amount) by customer"```

```
customer  amount
jack      115.00
jane        6.00
```

## As a command line utility for histogramming

Histograms are indespensible for understanding value distributions in a data set--especially distributions with a long tail or heavy skew like response times in computer systems or cost of goods on Amazon. Typically it is difficult to pick appropriate bin widths if you don't already have a solid understanding of the data. Shades implements dynamic rebalancing histograms based on [this paper](http://pages.cs.wisc.edu/~donjerko/hist.pdf) so they always make sense for your data set.

Say another file with the same structure as above includes one-minute system load averages as ```load1```

```
cat hoststats.txt | histo load1
     0.174 (  7) #######
     0.805 ( 30) ##############################
     1.974 ( 11) ###########
     2.936 ( 10) ##########
     3.911 (  8) ########
     5.164 (  5) #####
     6.744 (  7) #######
     7.852 (  4) ####
     9.310 (  1) #
    20.250 (  1) #
```

Each of these lines is a histogram bucket with the average value on the left and the number of items in the bucket in parenthesis. So the line ```5.164 (  5) #####``` can be read as "there are 5 values with a mean close to 5.164".

You can even feed data cubing output from above into the ```histo``` utility. Let's say we look back at the customer transaction data from above. To get a sense of the distribution of transaction amounts, you would simply do the following.

```
cat transactions.txt | shades -p "sum(amount) by transactionid" | histo amount
```

## Use in code

Shades also offers a public OLAP cubing API. See the ```shades``` and ```histo``` utilities for examples of building data cubes and histograms, respectively.

## Roadmap

- Add 'where' clauses for filtering
- Numerosity bounding of output from ```shades``` by only including the top ranking rows in a set of dimensions.
