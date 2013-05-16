# Derived from:
# https://gist.github.com/darylf/1175908

# Combined from:
#   [1] http://www.rubyinside.com/how-to-rails-3-and-rspec-2-4336.html
#   [2] https://gist.github.com/600976

unless defined?(GROWL)
  $stderr.sync=true
  $stdout.sync=true
  ENV["WATCHR"] = "1"
  GROWL=`which growlnotify`.chomp
  IMAGE_DIR=File.expand_path("~/.watchr_images/")
end

def growl(message,title=nil,image=nil)
  return if GROWL.empty?
  title ||= "Watchr Test Results"
  message.gsub! /\[[0-9]+?m/, ''
  image ||= message =~ /^0 failure/ ? "#{IMAGE_DIR}/pass.png" : "#{IMAGE_DIR}/fail.png"
  options = "-n Watchr --image '#{image}' -m '#{message}' '#{title}'"
  puts "#{GROWL} #{options}"
  run "#{GROWL} #{options}"
end

def run(cmd,verbose=true)
  puts("# #{cmd}")
  ret=[]
  IO.popen(cmd) do |output| 
    while line = output.gets do
      puts line if verbose
      ret << line
    end
  end
  ret #join("\n")
end

def generate_message(result)
  message = "Error finding results..."
  if result.join("\n") =~ /.*(\d+) example(s?), (\d+) failure(s?).*/
    message = "#{$3} failure"
    message += "s" unless $3 == "1"
  end
  message
end

def run_suite
  system("clear")
  results = run "rake spec"
  growl generate_message(results)
  puts
end

def run_spec(file)
  unless File.exist?(file)
    puts "#{file} does not exist"
    return
  end

  puts "Running #{file}"
  results = run "bundle exec rspec #{file}"
  growl generate_message(results)
  puts
end

watch("spec/.*/*_spec.rb") do |match|
  run_spec match[0]
end

watch("spec/.*/.*/*_spec.rb") do |match|
  run_spec match[0]
end

watch("lib/(.*).rb") do |match|
  run_spec %{spec/#{match[1]}_spec.rb}
end

watch("lib/heirloom/(.*).rb") do |match|
  run_spec %{spec/#{match[1]}_spec.rb}
end


# Ctrl-\
Signal.trap 'QUIT' do
  puts " --- Running all tests ---\n\n"
  run_suite
end

# Ctrl-C
Signal.trap 'INT' do
  if @interrupted then
    abort("\n")
  else
    puts "Interrupt a second time to quit"
    @interrupted = true
    Kernel.sleep 1.5
    # raise Interrupt, nil # let the run loop catch it
    run_suite
    @interrupted = false
  end
end
