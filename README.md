[![Build Status](https://travis-ci.com/shagabutdinov/webshipper-task.svg?branch=master)](https://travis-ci.com/shagabutdinov/webshipper-task)

Webshipper Test Task
====================

* [Task description](task.md)
* [Frontend](http://github.com/shagabutdinov/webshipper-frontend-task)

Comments
--------

I've made the straightforward implementation of currency conversion service. It
contains values conversions and error handling.

Installation
------------

```
$ git clone git@github.com:shagabutdinov/webshipper-task.git
$ cd webshipper-task
$ bundle install
```

Usage
-----

```
# start application
$ bundle exec ruby app.rb

# execute request
$ curl -v 'http://localhost:4567/?from=USD&to=EUR&value=100'
> 85.955

# execute tests
$ bundle exec rspec
> ...........
>
> Finished in 0.38226 seconds (files took 0.31914 seconds to load)
> 11 examples, 0 failures

# execute rubocop
$ rubocop -a
> Inspecting 7 files
> .......
>
> 7 files inspected, no offenses detected
```
