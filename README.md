# VariaModel
[![Build Status](https://secure.travis-ci.org/RiotGames/varia_model.png?branch=master)](http://travis-ci.org/RiotGames/varia_model)
[![Dependency Status](https://gemnasium.com/RiotGames/varia_model.png?travis)](https://gemnasium.com/RiotGames/varia_model)
[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/RiotGames/varia_model)

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

* Jamie Winsor (<reset@riotgames.com>)
