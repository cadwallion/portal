require 'csv'
require 'portal_version'

module Portal
  class << self
    attr_writer :conf_file

    def conf_file
      @conf_file ||= File.expand_path("~/.ssh/config")
    end

    def portals
      unless @portals
        lines = File.readlines(conf_file)
        host_block = false
        hosts = {}
        host = {}
        name = nil
        lines.each do |line|
          if match = line.match(/Host (.+)/)
            hosts[name] = host.dup
            host = {}
            name = match[1]
            host_block = true
          else
            if host_block
              match = line.match(/(\S+) (.+)$/)
              host[match[1]] = match[2]
            else
              # blank line, extra, unparseable info
            end
          end
        end
        @portals = hosts
      end
      @portals
    end

    def clear_all
      @portals = nil
    end

    def clear_all!
      clear_all
      File.open(conf_file, 'w+') { |f| }
    end

    def add name, domain, options = {}
      if !portals.keys.include? name
        host = {}
        host['HostName'] = domain 
        host['Port'] = options[:port] if options[:port]
        host['User'] = options[:user] if options[:user]
        portals[name] = host
        write_to_conf
      else
        raise 'Duplicate portal name found.'
      end
    end

    def remove name
      if portals.keys.include? name
        portals.delete(name)
        write_to_conf
      else
        raise 'No portal of that name found.'
      end
    end

    def list
      if !portals.empty?
        output = "List of portals: \n\n"
        portals.each_key do |key|
          portal = portals[key]
          output << "#{key} -"
          portal.each_key do |pk|
            output << " #{pk}: #{portal[pk]}" unless portal[pk].nil?
          end
          output << "\n"
        end
        return output
      else
        return "No portals found"
      end
    end

    def write_to_conf
      file = File.open(conf_file, 'w+')

      portals.each_key do |key|
        file << "Host #{key}\n"
        portal = portals[key]
        portal.each_key do |k|
          file << "  #{k} #{portal[k]}\n" 
        end
      end
      file.close
    end
  end
end
