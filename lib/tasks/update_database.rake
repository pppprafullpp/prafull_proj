namespace :update_database do


  task update_effective_price_in_deals: :environment do
    deals = Deal.all
    deals.each do |deal|
      effective_price = deal.get_effective_price
      puts "--------------#{effective_price}------------"
      deal.update_attributes(:effective_price => effective_price)
    end
  end


  task update_effective_price_in_cellphone_deal_attributes: :environment do
    deals = CellphoneDealAttribute.all
    deals.each do |deal|
      deal.save!
    end
  end

  task create_multiline_deal_attribute_for_cellphone_deals: :environment do
    service_category = ServiceCategory.where(:name => ServiceCategory::CELLPHONE_CATEGORY).first
    deals = Deal.where(:service_category_id => service_category.id)
    deals.each do |deal|
      cellphone_deal_attribute = CellphoneDealAttribute.where(:deal_id => deal.id,:no_of_lines => 1).first
      if cellphone_deal_attribute.present?
        price_per_line = cellphone_deal_attribute.price_per_line
        data_plan_price = cellphone_deal_attribute.data_plan_price
        additional_data_price = cellphone_deal_attribute.additional_data_price
        domestic_call_minutes = cellphone_deal_attribute.domestic_call_minutes
        domestic_text = cellphone_deal_attribute.domestic_text
        international_call_minutes = cellphone_deal_attribute.international_call_minutes
        international_text = cellphone_deal_attribute.international_text
        data_plan = cellphone_deal_attribute.data_plan
        additional_data = cellphone_deal_attribute.additional_data
        rollover_data = cellphone_deal_attribute.rollover_data
        equipment=deal.cellphone_equipments.first
        for i in 2..4
          cellphone_deal_attribute_new = CellphoneDealAttribute.find_or_initialize_by(:deal_id => deal.id,:no_of_lines => i)
          effective_price=(i*price_per_line)+data_plan_price+additional_data_price
          if equipment.present?
            effective_price+=(i*equipment.price)
          end
          if deal.additional_offers.present?
            deal.additional_offers.each do |additional_offer|
              effective_price-=additional_offer.price
            end
          end
          cellphone_deal_attribute_new.effective_price = effective_price
          cellphone_deal_attribute_new.price_per_line = price_per_line
          cellphone_deal_attribute_new.data_plan_price = data_plan_price
          cellphone_deal_attribute_new.additional_data_price = additional_data_price
          cellphone_deal_attribute_new.domestic_call_minutes = domestic_call_minutes
          cellphone_deal_attribute_new.domestic_text = domestic_text
          cellphone_deal_attribute_new.international_call_minutes = international_call_minutes
          cellphone_deal_attribute_new.international_text = international_text
          cellphone_deal_attribute_new.data_plan = data_plan
          cellphone_deal_attribute_new.additional_data = additional_data
          cellphone_deal_attribute_new.rollover_data = rollover_data
          cellphone_deal_attribute_new.save
        end
      end
    end
  end

  task update_deal_equipments_set_deal_id: :environment do
    deals = Deal.all
    deals.each do |deal|
      category_name = ServiceCategory.where(:id => deal.service_category_id).pluck(:name).first.downcase
      attributes = eval("#{category_name.camelcase}DealAttribute").where(:deal_id => deal.id)
      attributes.each do |attribute|
        equipments = eval("#{category_name.camelcase}Equipment").where("#{category_name}_deal_attribute_id".to_sym => attribute.id)
        puts "--------------#{deal.id}------#{attribute.id}------"
        equipments.update_all(:deal_id => deal.id)
      end
    end
  end

 #task to map city and states
   task map_state_and_city: :environment do
     state_list=["TX", "NY", "OH", "NE", "SC", "CA", "PA", "NM", "NJ", "NC", "MO", "KS", "WI", "MI", "VA", "AL", "HI", "MA", "CO", "ID", "WA", "TN", "AZ", "ME", "NH", "IN", "KY", "WV", "IL", "VT", "FL", "RI", "CT", "DE", "DC", "MD", "GA", "AA", "MS", "IA", "MN", "SD", "ND", "MT", "LA", "AR", "OK", "WY", "UT", "NV", "AP", "GU", "PW ", "FM", "MP ", "MH ", "OR", "AK"]
     state_list.each do | state |
       puts "Mapping for "+state.downcase
         begin
             api_datas=JSON.parse(URI.parse("http://api.sba.gov/geodata/city_links_for_state_of/"+state+".json").read)
             api_datas.each do |api_data|
               city=api_data["name"]
               state=api_data["state_abbreviation"]
               county=api_data["county_name"]
               Statelist.create!(:state=>state, :city=>city, :county=>county)
               puts "Cities mapped for "+state
             end
         rescue
               puts "bad request for "+state.downcase
         end
     end
   end
   task encrypt_data: :environment do
     obj=ApplicationController.new
     @user=AppUser.all
    #  begin
       @user.each do |user_data|
        fname=user_data.first_name
        lname=user_data.last_name
        zip=user_data.zip
        if user_data.business_app_users.present?
        business_id=user_data.business_app_users[0]["business_id"].to_s
        if Business.exists?(business_id)
              business_info=Business.find(business_id)
              if business_info.federal_number.present?
                  business_federal_number=business_info.federal_number
              else
                 business_ssn=business_info.ssn
              end
            end
         end
        if fname.present?
          fname=obj.encode_api_data(fname)
          puts "first name=#{fname}"
        end
        if lname.present?
          lname=obj.encode_api_data(lname)
          puts "last name=#{lname}"
        end
        if zip.present?
          zip=obj.encode_api_data(zip)
          puts "zip=#{zip}"
        end
        if business_federal_number.present?
           business_federal_number=obj.encode_api_data(business_federal_number)
           puts "federal number=#{business_federal_number}"
        end
        if business_ssn.present?
           business_ssn=obj.encode_api_data(business_ssn)
           puts "ssn=#{business_ssn}"
        end
        user_data.update_attributes(:first_name=>fname, :last_name=>lname, :zip=>zip)
        if Business.exists?(business_id)
           Business.find(business_id).update_attributes(:ssn=>business_ssn, :federal_number=>business_federal_number)
        end
        puts "updated"
      end
    # rescue Exception => e

      # next
    # end
 end
end
