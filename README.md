[![Build Status](https://travis-ci.org/Cogibara/cogibara.png?branch=master)](https://travis-ci.org/Cogibara/cogibara) |
[![Code Climate](https://codeclimate.com/github/Cogibara/cogibara.png)](https://codeclimate.com/github/Cogibara/cogibara)

Cogibara README
================

## Overview

Cogibara is a framework for building natural language interfaces. It takes care of receiving and processing messages, and allows users with any level of Ruby familiarity to focus on defining actual behavior.

The version in this repository is something of a 'kitchen sink' demonstration, with every module and inteface I've written so far. Eventually the core classes will be separated out into a gemified version which will have a minimum of dependancies.

## Installing

Clone the repository, then run

`bundle install`

## Usage

Start one of the interfaces in the bin directory. For example, try running `./bin/cogibara-local`, and typing a message.

#### Writing a module

(coming soon)

## Key components

  * Simple DSL for responding to linguistic features of user input
  * Modular design allowing mix and match of response behaviors
  * All data stored as RDF triples using ruby-rdf; enhanced persistence, storage
  * Automatically use or provide access to Natural Language Processing tools.

#### Module DSL

(coming soon)

#### Semantic Memory

(coming soon)

#### NLP Tools
  
Every Cogibara module has easy access to a variety of tools for analyzing input as natural language.

  * Configuration free Intent and Named Entity Recognition with Maluuba
  * Domain free Intent and NER with Wit that learns its domain over time
  * Named Entity Recognition and Disambiguation with DBPedia Spotlight
  * Query normalization with Maluuba
  * Time normalization with Chronic
  * (Soon) Many lower level linguistic tools using TREAT


#### Service APIs / gems

  * DBPedia SPARQL endpoint
  * DBPedia Spotlight gem
  * Wit Natural Language Processing
  * Maluuba Natural Language Service
  * Yummly Recipe search
  * ...



-
(Beyond this is the daemon kit default readme. more will be added soon)

daemon-kit has generated a skeleton Ruby daemon for you to build on. Please read
through this file to ensure you get going quickly.

Directories
====

bin/
  cogibara - Stub executable to control your daemon with

config/
  Environment configuration files

lib/
  Place for your libraries

libexec/
  cogibara.rb - Your daemon code

log/
  Log files based on the environment name

spec/
  rspec's home

tasks/
  Place for rake tasks

vendor/
  Place for third-party code that can't be bundled via the Gemfile

tmp/
  Scratch folder

Rake Tasks
==========

Note that the Rakefile does not load the `config/environments.rb` file, so if you have
environment-specific tasks (such as tests), you will need to call rake with the environment:

    DAEMON_ENV=staging bundle exec rake -T

Logging
=======

One of the biggest issues with writing daemons are getting insight into what your
daemons are doing. Logging with daemon-kit is simplified as DaemonKit creates log
files per environment in log.

On all environments except production the log level is set to DEBUG, but you can
toggle the log level by sending the running daemon SIGUSR1 and SIGUSR2 signals.
SIGUSR1 will toggle between DEBUG and INFO levels, SIGUSR2 will blatantly set the
level to DEBUG.

Bundler
=======

daemon-kit uses bundler to ease the nightmare of dependency loading in Ruby
projects. daemon-kit and its generators all create/update the Gemfile in the
root of the daemon. You can satisfy the project's dependencies by running
`bundle install` from within the project root.

For more information on bundler, please see http://github.com/carlhuda/bundler
