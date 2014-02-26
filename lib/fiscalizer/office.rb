class Fiscalizer
	class Office

		attr_accessor	:uuid, :time_sent, :pin, 
						:office_label, :adress_street_name, :adress_house_num,
						:adress_house_num_addendum, :adress_post_num, :adress_settlement,
						:adress_township, :adress_other, :office_time,
						:take_effect_date, :closure_mark, :specific_purpose,
						:generated_xml

		def initialize(	uuid: nil, time_sent: nil, pin: nil, 
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
		def time_sent_str separator="T"
			return @time_sent.strftime('%d.%m.%Y') + separator + @time_sent.strftime('%H:%M:%S')
		end # time_issued_str

		def take_effect_date_str
			return @take_effect_date.strftime('%d.%m.%Y')
		end # time_sent_str

		def is_valid
			# Check values
			return false if @uuid == nil 				
			return false if @time_sent == nil 			
			return false if @pin == nil 				
			return false if @office_label == nil
			return false if @office_time == nil			
			return false if @take_effect_date == nil
			# Check adress
			if @adress_other == nil
				return false if @adress_street_name == nil
				return false if @adress_house_num == nil 
				return false if @adress_house_num_addendum == nil 
				return false if @adress_post_num == nil 
				return false if @adress_settlement == nil 
				return false if @adress_township == nil 
			end
			return true
		end # is_valid
		alias_method :valid?, :is_valid
		alias_method :valdate, :is_valid

	end # Office
end # Fiscalizer