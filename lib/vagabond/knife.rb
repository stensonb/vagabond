#encoding: utf-8
require 'thor'
require 'elecksee/lxc'

#TODO: Remove this when elecksee gets updated
require 'chef/log'

%w(helpers vagabondfile internal_configuration).each do |dep|
  require "vagabond/#{dep}"
end

module Vagabond
  class Knife < Thor

    include Thor::Actions
    include Helpers

    def initialize(*args)
      super
    end

    desc 'knife COMMAND', 'Run knife commands against local Chef server'
    def knife(command, *args)
      @options = options.dup
      @vagabondfile = Vagabondfile.new(options[:vagabond_file])
      options[:disable_solo] = true
      options[:sudo] = sudo
      Lxc.use_sudo = @vagabondfile[:sudo].nil? ? true : @vagabondfile[:sudo]
      @internal_config = InternalConfiguration.new(@vagabondfile, nil, options)
      unless(options[:local_server])
        if(@vagabondfile[:local_chef_server] && @vagabondfile[:local_chef_server][:enabled])
          srv = Lxc.new(@internal_config[:mappings][:server])
          if(srv.running?)
            proto = @vagabondfile[:local_chef_server][:zero] ? 'http' : 'https'
            options[:knife_opts] = " --server-url #{proto}://#{srv.container_ip(10, true)}"
          else
            options[:knife_opts] = ' -s https://no-local-server'
          end
        end
      end
      command_string = [command, args.map{|s| "'#{s}'"}].flatten.compact.join(' ')
      if(ENV['VAGABOND_KNIFE_DEBUG'])
        puts "knife #{command_string} #{options[:knife_opts]}"
      end
      exec("knife #{command_string} #{options[:knife_opts]}")
    end
  end
end
