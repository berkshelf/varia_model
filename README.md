# VariaModel
[![Gem Version](https://badge.fury.io/rb/varia_model.png)](http://badge.fury.io/rb/varia_model)
[![Build Status](https://secure.travis-ci.org/RiotGames/varia_model.png?branch=master)](http://travis-ci.org/RiotGames/varia_model)

A mixin to provide objects with magic attribute reading and writing

## Installation

    $ gem install varia_model

## Usage

    require 'varia_model'

    module MyApp
      class Config
        include VariaModel
      end
    end

# Authors and Contributors

* Jamie Winsor (<jamie@vialstudios.com>)

Thank you to all of our [Contributors](https://github.com/RiotGames/buff-extensions/graphs/contributors), testers, and users.
