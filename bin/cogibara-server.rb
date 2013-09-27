#!/usr/bin/env ruby
#
# Stub executable for cogibara
#
require "bundler/setup"

require File.expand_path('../../config/boot',  __FILE__)

Bundler.setup :default #, DaemonKit.env

require_relative '../lib/cogibara.rb'
require_relative '../server/server.rb'
