# HTTPI2

A common interface for Ruby's HTTP libraries.

[Documentation](http://httpi2rb.com) | [RDoc](http://rubydoc.info/gems/httpi2) |
[Mailing list](https://groups.google.com/forum/#!forum/httpi2rb)

[![Build Status](https://secure.travis-ci.org/savonrb/httpi2.png?branch=master)](http://travis-ci.org/savonrb/httpi2)
[![Gem Version](https://badge.fury.io/rb/httpi2.png)](http://badge.fury.io/rb/httpi2)
[![Code Climate](https://codeclimate.com/github/savonrb/httpi2.png)](https://codeclimate.com/github/savonrb/httpi2)
[![Coverage Status](https://coveralls.io/repos/savonrb/httpi2/badge.png?branch=master)](https://coveralls.io/r/savonrb/httpi2)


## Installation

HTTPI2 is available through [Rubygems](http://rubygems.org/gems/httpi2) and can be installed via:

```
$ gem install httpi2
```

or add it to your Gemfile like this:

```
gem 'httpi2', '~> 2.1.0'
```


## Usage example


``` ruby
require "httpi2"

# create a request object
request = HTTPI2::Request.new
request.url = "http://example.com"

# and pass it to a request method
HTTPI2.get(request)

# use a specific adapter per request
HTTPI2.get(request, :curb)

# or specify a global adapter to use
HTTPI2.adapter = :httpclient

# and execute arbitary requests
HTTPI2.request(:custom, request)
```


## Documentation

Continue reading at [httpi2rb.com](http://httpi2rb.com)
