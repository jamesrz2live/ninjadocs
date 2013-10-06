module NinjaDocs

  class Events
    def initialize
      @listeners = {}
    end

    def on event, &block
      if @listeners.has_key? event
        @listeners[event] << block
      else
        @listeners[event] = [block]
      end
    end

    def emit event, payload = {}
      listeners = @listeners[event]
      return if listeners.nil?
      listeners.each() { |block|
        block.call(payload)
      }
    end
  end

end
