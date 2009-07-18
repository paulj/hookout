require 'optparse'
require 'yaml'

module Hookout  
  # Hookout overrides of the Hookout runner
  class Runner < Thin::Runner
    def parser
      # Load in Hookup specific defaults
      # Default options values
      @options[:address] = ReverseHttpConnector::DEFAULT_SERVER
      @options[:label] = ReverseHttpConnector::DEFAULT_LABEL
      @options[:log] = 'log/hookout.log'
      @options[:pid] = 'tmp/pids/hookout.pid'
      @options[:backend] =Hookout::ThinBackend.name
      
      # NOTE: If you add an option here make sure the key in the +options+ hash is the
      # same as the name of the command line option.
      # +option+ keys are used to build the command line to launch other processes,
      # see <tt>lib/thin/command.rb</tt>.
      @parser ||= OptionParser.new do |opts|
        opts.banner = "Usage: hookout [options] #{self.class.commands.join('|')}"

        opts.separator ""
        opts.separator "Server options:"

        opts.on("-a", "--address SERVER", "use SERVER for Reverse HTTP bindings " +
                                        "(default: #{@options[:address]})")             { |host| @options[:address] = host }
        opts.on("-n", "--label LABEL", "use LABEL (default: #{@options[:label]})")      { |label| @options[:label] = label }
        opts.on("-A", "--adapter NAME", "Rack adapter to use (default: autodetect)",
                                        "(#{Rack::ADAPTERS.map{|(a,b)|a}.join(', ')})") { |name| @options[:adapter] = name }
        opts.on("-R", "--rackup FILE", "Load a Rack config file instead of " +
                                       "Rack adapter")                                  { |file| @options[:rackup] = file }
        opts.on("-c", "--chdir DIR", "Change to dir before starting")                   { |dir| @options[:chdir] = File.expand_path(dir) }
        opts.on(      "--stats PATH", "Mount the Stats adapter under PATH")             { |path| @options[:stats] = path }
        
        opts.separator ""
        opts.separator "Adapter options:"
        opts.on("-e", "--environment ENV", "Framework environment " +                       
                                           "(default: #{@options[:environment]})")      { |env| @options[:environment] = env }
        opts.on(      "--prefix PATH", "Mount the app under PATH (start with /)")       { |path| @options[:prefix] = path }
        
        unless Thin.win? # Daemonizing not supported on Windows
          opts.separator ""
          opts.separator "Daemon options:"
                                                                                      
          opts.on("-d", "--daemonize", "Run daemonized in the background")              { @options[:daemonize] = true }
          opts.on("-l", "--log FILE", "File to redirect output " +                      
                                      "(default: #{@options[:log]})")                   { |file| @options[:log] = file }
          opts.on("-P", "--pid FILE", "File to store PID " +                            
                                      "(default: #{@options[:pid]})")                   { |file| @options[:pid] = file }
          opts.on("-u", "--user NAME", "User to run daemon as (use with -g)")           { |user| @options[:user] = user }
          opts.on("-g", "--group NAME", "Group to run daemon as (use with -u)")         { |group| @options[:group] = group }
                                                                                      
          opts.separator ""
          opts.separator "Cluster options:"                                             
                                                                                      
          opts.on("-s", "--servers NUM", "Number of servers to start")                  { |num| @options[:servers] = num.to_i }
          opts.on("-o", "--only NUM", "Send command to only one server of the cluster") { |only| @options[:only] = only }
          opts.on("-C", "--config FILE", "Load options from config file")               { |file| @options[:config] = file }
          opts.on(      "--all [DIR]", "Send command to each config files in DIR")      { |dir| @options[:all] = dir } if Thin.linux?
        end
        
        opts.separator ""
        opts.separator "Tuning options:"
        
        opts.on("-b", "--backend CLASS", "Backend to use (ignored)")                    { |name|  }
        opts.on("-p", "--port PORT",     "Port to use (ignored)")                       { |name|  }
        opts.on("-t", "--timeout SEC", "Request or command timeout in sec " +            
                                       "(default: #{@options[:timeout]})")              { |sec| @options[:timeout] = sec.to_i }
        opts.on("-f", "--force", "Force the execution of the command")                  { @options[:force] = true }
        opts.on(      "--max-conns NUM", "Maximum number of connections " +
                                         "(default: #{@options[:max_conns]})",
                                         "Might require sudo to set higher then 1024")  { |num| @options[:max_conns] = num.to_i } unless Thin.win?
        opts.on(      "--max-persistent-conns NUM",
                                       "Maximum number of persistent connections",
                                       "(default: #{@options[:max_persistent_conns]})") { |num| @options[:max_persistent_conns] = num.to_i }
        opts.on(      "--threaded", "Call the Rack application in threads " +
                                    "[experimental]")                                   { @options[:threaded] = true }
        opts.on(      "--no-epoll", "Disable the use of epoll")                         { @options[:no_epoll] = true } if Thin.linux?
        
        opts.separator ""
        opts.separator "Common options:"

        opts.on_tail("-r", "--require FILE", "require the library")                     { |file| @options[:require] << file }
        opts.on_tail("-D", "--debug", "Set debbuging on")                               { @options[:debug] = true }
        opts.on_tail("-V", "--trace", "Set tracing on (log raw request/response)")      { @options[:trace] = true }
        opts.on_tail("-h", "--help", "Show this message")                               { puts opts; exit }
        opts.on_tail('-v', '--version', "Show version")                                 { puts Thin::SERVER; exit }
      end
    end
  end
end
