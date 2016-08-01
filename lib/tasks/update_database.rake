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

end
