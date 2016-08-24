# VariaModel

[![Gem Version](https://badge.fury.io/rb/varia_model.svg)](http://badge.fury.io/rb/varia_model) [![Build Status](https://travis-ci.org/berkshelf/varia_model.svg?branch=master)](http://travis-ci.org/berkshelf/varia_model)

A mixin to provide objects with magic attribute reading and writing

## Installation

```sh
$ gem install varia_model
```

## Usage

```ruby
require 'varia_model'

module MyApp
  class Config
    include VariaModel
  end
end
```

# Authors and Contributors

- Jamie Winsor ([jamie@vialstudios.com](mailto:jamie@vialstudios.com))

Thank you to all of our [Contributors](https://github.com/berkshelf/varia_model/graphs/contributors), testers, and users.
