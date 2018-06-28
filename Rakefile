require 'rubygems'
require 'bundler'

Bundler.setup :default, :development

$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'tasks/logger'

task :environment do
  require 'slack-gamebot'
end

unless ENV['RACK_ENV'] == 'production'
  require 'rspec/core'
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:spec) do |spec|
    spec.pattern = FileList['spec/**/*_spec.rb']
  end

  require 'rubocop/rake_task'
  RuboCop::RakeTask.new

  task default: [:rubocop, :spec]

  import 'tasks/db.rake'
end

import 'tasks/scheduler.rake'
