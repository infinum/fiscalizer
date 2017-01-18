class Fiscalizer
  class Echo
    def initialize(message:)
      @message = message
    end

    attr_reader :message
    attr_accessor :generated_xml
  end
end
