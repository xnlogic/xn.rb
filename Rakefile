require 'bundler'
Bundler::GemHelper.install_tasks

require 'xn_gem_release_tasks'
task :not_allowed do
  raise "Deploying to Rubygems.org...That's not allowed!"
end
task :release => :not_allowed
task :release_with => :up
