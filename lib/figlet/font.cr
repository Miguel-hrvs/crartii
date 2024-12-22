module Artii
  module Figlet
    class UnknownFontFormat < Exception
    end

    class Font
      @hard_blank : String
      @height : Int32
      @baseline : String
      @max_length : String
      @old_layout : Int32
      @comment_count : Int32
      @right_to_left : Bool

      def initialize(filename, load_german = true)
        file = File.open(filename, "rb")

        header_line = file.gets
        raise UnknownFontFormat.new if header_line.nil?

        header = header_line.strip.split(/ /)

        raise UnknownFontFormat.new if "flf2a" != header[0][0, 5]

        @hard_blank = header.shift[-1, 1]
        @height = header.shift.to_i
        @baseline = header.shift
        @max_length = header.shift
        @old_layout = header.shift.to_i
        @comment_count = header.shift.to_i
        right_to_left_value = header.shift # Get the value as a String
        @right_to_left = !right_to_left_value.nil? && right_to_left_value.to_i == 1

        @load_german, @characters = load_german, {} of String => String
        load_comments file
        load_ascii_characters file
        load_german_characters file
        load_extended_characters file

        file.close
      end

      def [](char)
        @characters[char]
      end

      def has_char?(char)
        @characters.has_key? char
      end

      getter :height, :hard_blank, :old_layout

      def right_to_left?
        @right_to_left
      end

      private def load_comments(file)
        @comment_count.times do
          line = file.gets
          line = line.try(&.strip) || ""
        end
      end

      def load_ascii_characters(file)
        (32..126).each do |i|
          @characters[i.to_s] = load_char(file).to_s # Convert Array(Char) to String
        end
      end

      def load_german_characters(file)
        [91, 92, 93, 123, 124, 125, 126].each do |i|
          if @load_german
            unless char = load_char(file)
              return
            end
            @characters[i.to_s] = load_char(file).to_s
          else
            skip_char file
          end
        end
      end

      def load_extended_characters(file)
        until file.gets.nil?
          i = file.gets.to_s.strip.split(/ /).first
          if !i || i.empty?
            next
          elsif /^\-0x/i =~ i # comment
            skip_char file
          else
            if /^0x/i =~ i
              i = i[2, 1].to_i(16)
            elsif "0" == i[0]? && "0" != i || "-0" == i[0, 2]
              i = i.to_i(8)
            end
            unless char = load_char(file)
              return
            end
            @characters[i.to_s] = char.to_s
          end
        end
      end

      def load_char(file)
        char = [] of Char
        @height.times do
          return false if file.gets.nil?
          line = file.gets.to_s.rstrip
          if match = /(.){1,2}$/.match(line)
            line.gsub match[1], ""
          end
          line += "\x00"
          char += line.chars
        end
        return char
      end

      def skip_char(file)
        @height.times do
          return if file.gets.to_s.strip.nil?
        end
      end
    end
  end # module Figlet
end   # module Artii
