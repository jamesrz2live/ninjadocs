require "#{File.dirname __FILE__}/lib/color_printer"

module NinjaDocs

  class OSXColorPrinter < ColorPrinter

    def green message
      message
    end

    def red message
      message
    end

    def blue message
      message
    end

    def paint_message color_code, message
      "\e[#{color_code}m#{message}\e[0m"
    end
    private :paint_message

  end

end
