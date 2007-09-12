# desc 'Default task for cruise control'
# task :cruise => ['test:coverage:cruise:test'] do
# end

task :cruise => ['db:migrate', 'test', 'test:flog']