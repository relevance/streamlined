namespace :test do
  task :flog do
    threshold = (ENV['FLOG_THRESHOLD'] || 120).to_i
    result = IO.popen('flog app 2>/dev/null | grep "(" | grep -v "main#none" | grep -v "AccountController#login" | head -n 1').readlines.join('')
    result =~ /\((.*)\)/
    flog = $1.to_i
    result =~ /^(.*):/
    method = $1
    if flog > threshold
      raise "FLOG failed for #{method} with score of #{flog} (threshold is #{threshold})."
    end  
    puts "FLOG passed, with highest score being #{flog} for #{method}."
  end
end