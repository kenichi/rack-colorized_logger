require 'term/ansicolor'
class ::String; include ::Term::ANSIColor; end

module Rack
  class ColorizedLogger

    DEFAULT_COLORS = {
      :params =>  [:blue, :red],
      :session => [:cyan, :yellow],
      :cookies => [:green, :magenta]
    }

    DEFAULT_OUTPUT = STDOUT

    attr_writer :public, :colors, :out, :path, :assets

    def initialize(app)
      @app = app

      if defined? Rails
        @path = false
        @public = ::File.join Rails.root, 'public'
        @assets = '/assets'
      else
        @path = true
        @public = nil
        @assets = nil
      end

      yield self if block_given?

      @colors ||= (defined? Rack::ColorizedLogger::COLORS) ? Rack::ColorizedLogger::COLORS : DEFAULT_COLORS
      @out ||= DEFAULT_OUTPUT
      @public_map = Dir[::File.join(@public, '**', '*')].map {|f| ::File.basename f} if @public and ::File.directory? @public
    end

    def call env
      @request = Rack::Request.new(env)
      if not public_file? and not asset?
        @out.puts "path:".bold + " " + @request.path if @path
        @colors.each do |thing, color_a|
          if thing.respond_to? :call
            _thing = thing.call(@request)
            @out.puts "#{_thing[0]}:".send(color_a[0]).bold
            pretty_colors_h _thing[1], *color_a
          else
            @out.puts "#{thing.to_s}:".send(color_a[0]).bold
            pretty_colors_h @request.send(thing), *color_a
          end
        end
      end

      @app.call env
    end

    private

    def public_file?
      !@public_map.select {|p| @request.path.index(%{/#{p}}) == 0}.empty? if @public_map and not @public_map.empty?
    end

    def asset?
      @request.path.index(@assets) == 0 unless @assets.nil?
    end

    def pretty_colors_h(hash, k_color, v_color = nil, padding = 1, start = true)
      v_color ||= k_color
      indent = padding + 1
      @out.puts sprintf("%1$*2$s", "{", padding).blue if start
      hash.each do |k,v|
        if v.is_a?(Hash)
          @out.puts sprintf("%1$*2$s","",indent) + "#{k.to_s.bold.send(k_color)} => " + "{".blue
          pretty_colors_h(v, k_color, v_color, padding+2, false)
        elsif v.is_a?(Array)
          @out.puts sprintf("%1$*2$s","",indent) + "#{k.to_s.bold.send(k_color)} => " + pretty_colors_a(v, v_color)
        else
          @out.puts sprintf("%1$*2$s","",indent) + "#{k.to_s.bold.send(k_color)} => #{v.to_s.bold.send(v_color)}"
        end
      end
      @out.puts sprintf("%1$*2$s", "}", padding).blue
    end

    def pretty_colors_a(array, color)
      "[" + array.map {|e| [Array,Hash].include?(e.class) ? e.inspect.bold.send(color) : e.bold.send(color)}.join(",") + "]"
    end
  end
end
