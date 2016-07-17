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


end