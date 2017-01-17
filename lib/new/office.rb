class Fiscalizer
  class Office
    # rubocop:disable Metrics/ParameterLists, Metrics/MethodLength
    def initialize(uuid:, time_sent:, pin:, office_label:, take_effect_date: nil,
                   adress_street_name: nil, adress_house_num: nil, adress_house_num_addendum: nil,
                   adress_post_num: nil, adress_settlement: nil, adress_township: nil,
                   adress_other: nil, office_time: nil, closure_mark: nil, specific_purpose: nil)

      @uuid = uuid
      @time_sent = time_sent
      @pin = pin
      @office_label = office_label
      @adress_street_name = adress_street_name
      @adress_house_num = adress_house_num
      @adress_house_num_addendum = adress_house_num_addendum
      @adress_post_num = adress_post_num
      @adress_settlement = adress_settlement
      @adress_township = adress_township
      @adress_other = adress_other
      @office_time = office_time
      @take_effect_date = take_effect_date
      @closure_mark = closure_mark
      @specific_purpose = specific_purpose
    end

    attr_reader :uuid, :time_sent, :pin, :office_label, :adress_street_name,
                :adress_house_num, :adress_house_num_addendum, :adress_post_num,
                :adress_settlement, :adress_township, :adress_other, :office_time,
                :take_effect_date, :closure_mark, :specific_purpose

    attr_accessor :generated_xml

    def time_sent_str(separator = 'T')
      time_sent.strftime("%d.%m.%Y#{separator}%H:%M:%S")
    end

    def take_effect_date_str
      take_effect_date.strftime('%d.%m.%Y')
    end
  end
end
