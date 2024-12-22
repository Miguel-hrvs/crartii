require "option_parser"

module Artii
  class CLI
    property params : Hash(String, String)
    property action : Symbol

    def initialize(args)
      @params = {} of String => String
      @action = :output

      parser = OptionParser.new do |parser|
        parser.banner = "Usage: artii (your string here) [-f FONT_NAME or --font FONT_NAME] [-l or --list]"

        parser.on("-f FONT_NAME", "--font FONT_NAME", "Specify the font to be used (defaults to big)") do |font|
          @params["font"] = font
        end

        parser.on("-l", "--list", "Prints the list of available fonts") do
          @action = :list_all_fonts
        end

        parser.on("-v", "--version", "Displays current version number") do
          @action = :version
        end

        parser.on("-h", "--help", "Show this message") do
          puts parser
          exit
        end

        if args.empty?
          puts parser
          exit
        end
      end

      parser.parse(args)

      @params["text"] = args.join " "

      @a = Artii::Base.new(@params)
    end

    def font_name
      @a.font_name
    end

    def output
      case @action
      when :output
        @a.output(@params["text"])
      when :list_all_fonts
        @a.list_all_fonts
      when :version
        @a.version
      else
        puts "Unknown action"
      end
    end
  end
end
