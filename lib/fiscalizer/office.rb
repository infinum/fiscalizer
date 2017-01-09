class Fiscalizer
  class Office
    attr_accessor :uuid, :time_sent, :pin,
                  :office_label, :adress_street_name, :adress_house_num,
                  :adress_house_num_addendum, :adress_post_num, :adress_settlement,
                  :adress_township, :adress_other, :office_time,
                  :take_effect_date, :closure_mark, :specific_purpose,
                  :generated_xml

    def initialize(uuid: nil, time_sent: nil, pin: nil,
                   office_label: nil, adress_street_name: nil, adress_house_num: nil,
                   adress_house_num_addendum: nil, adress_post_num: nil, adress_settlement: nil,
                   adress_township: nil, adress_other: nil, office_time: nil, take_effect_date: nil,
                   closure_mark: nil, specific_purpose: nil)
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
    end # initialize

    # Getters
    def time_sent_str(separator = 'T')
      @time_sent.strftime('%d.%m.%Y') + separator + @time_sent.strftime('%H:%M:%S')
    end # time_issued_str

    def take_effect_date_str
      @take_effect_date.strftime('%d.%m.%Y')
    end # time_sent_str

    def is_valid
      # Check values
      return false unless uuid && time_sent && pin && office_label && take_effect_date
      # Check adress
      if @adress_other.nil?
        return false unless adress_street_name && adress_house_num &&
                            adress_house_num_addendum && adress_post_num &&
                            adress_settlement && adress_township
      end
      true
    end # is_valid
    alias valid? is_valid
    alias valdate is_valid
  end # Office
end # Fiscalizer
