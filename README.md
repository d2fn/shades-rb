# Shades

Get a new perspective on your data. In-memory [OLAP cubing](en.wikipedia.org/wiki/OLAP_cube) for Ruby.

## As a command line utility

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

## Use in code

Shades also offers a public OLAP cubing API.

```
-- c o m i n g  s o o n --
```