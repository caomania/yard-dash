require 'yard'

@scope = %w[ --private --protected ]

task :default => [ :yard, :yard_stats ]

YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb']
  t.options = %w[ --no-stats ] + @scope
end

task :stats  => [:yard_stats]

task :yard_stats do
  options = %w[ lib/**/*.rb --list-undoc ] + @scope
  YARD::CLI::Stats.run(*options)
end

