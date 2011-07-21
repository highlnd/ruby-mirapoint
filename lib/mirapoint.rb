require 'socket'
require 'openssl'

module Mirapoint
  
  class Connection
    
    attr_reader :reported_hostname
    attr_reader :version
    attr_reader :connected
    attr_reader :sessionid
    attr_reader :okno

    def initialize(hostname, port=10143, ssl=false)
      @hostname = hostname
      @port = port
      @ssl = ssl
      @connected = false
    end

    def connect
      if @ssl
        ctx = OpenSSL::SSL::SSLContext.new()
        s = TCPSocket.new(@hostname, @port)
        @socket = OpenSSL::SSL::SSLSocket.new(s, ctx)
        @socket.connect
      else
        @socket = TCPSocket.new(@hostname, @port)
        @socket.connect        
      end

      @lasttag = 1
      
      # handshake
      response = @socket.gets
      
      if response
        
        r = /\* OK ([^ ]+) admind ([0-9\.]+).*/
        
        if(m = r.match response)
          @reported_hostname = m[1]
          @version = m[2]
          @connected = true
          return true
        end
        
        return false
      else
        return false
      end
      
    end
    
    def login(username, password)
      response = command("LOGIN", username, password)
      @sessionid = response[0]
      if /^OK/.match @okno
        return true
      end
      return false
    end
    
    def command(*cmds)
      
      puts cmds.size
      puts cmds.class

      tag = send_command(cmds)
 
      response = []
      
      if tag
        response = get_response(tag)        
      else
        return nil
      end
      
      return response
      
    end
        
    private
    
    def send_command(cmds)
      
      @lasttag = @lasttag + 1
      
      tag = @lasttag
      cmd = tag.to_s

      puts cmds.size
      puts cmd
      puts cmds.join(" ")
      
      if cmds.size < 2
        cmd = cmd + " " + cmds[0]
      else
        cmd = cmd + escape_args(cmds)
      end
      
      puts cmd
      
      if xmit(cmd)
        return tag
      end

      nil
      
    end
    
    def escape_args(cmds)
      
      cmd = ""
      
      cmds.each do |c|
        
        if (/^$/.match c) || (/[\(\)\s]/.match c)
          c = "\"" + c + "\""
        end
        
        cmd = cmd + " " + c
      
      end      
      
      cmd
        
    end
    
    def get_response(tag)
      
      response = Array.new
      @okno = nil
      
      loop do
        line = @socket.gets
        
        if /^\* #{tag} /.match line
          line.sub!(/^\* #{tag} /, "")
        elsif (/^#{tag} OK/.match line) || (/^#{tag} NO/.match line)
          line.sub!(/^#{tag} /, "")
          @okno = line
          return response
        else
          if line == ""
            return response
          end
        end
                
        response.push(line)
        
      end

    end
    
    def xmit(cmd)
    
      if @connected
          @socket.puts(cmd + "\r\n")
          return true
      end
      
      false
      
    end

  end
  
end
