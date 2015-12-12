include Moonshine
include Moonshine::Http

module Moonshine::Utils
  class StaticDirs < Middleware
    property dirs

    def initialize(@path : String, dir : String)
      @dirs = [] of String
      @dirs << dir
    end

    def initialize(@path : String, @dirs : Array(String))
    end

    def process_request(request : Request)
      match = request.path.match /\/#{@path}\//
      if match
        file = ""
        begin
          file = request.path.split("/#{@path}/")[1] as String
        rescue e
          if e.is_a? IndexError
            return nil
          end
          raise e
        end

        @dirs.each do |dir|
          filepath = File.join(`pwd`.chomp, dir, file as String)
          exists = File.exists?(filepath)
          if exists
            return Response.new(200, File.read(filepath),
                                headers = HTTP::Headers{"Content-Type": mime_type(filepath)})
          end
        end
        nil
      else
        nil
      end
    end

    private def mime_type(path)
      case File.extname(path)
      when ".txt"          then "text/plain"
      when ".htm", ".html" then "text/html"
      when ".css"          then "text/css"
      when ".js"           then "application/javascript"
      else                      "application/octet-stream"
      end
    end
  end
end
