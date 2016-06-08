class ServiceCategory < ActiveRecord::Base
  require 'csv'
  has_many :service_preferences, :dependent => :destroy
	has_many :deals, :dependent => :destroy
	has_many :service_providers, :dependent => :destroy
	has_many :advertisements, :dependent => :destroy
	has_many :service_provider_checklists, :dependent => :destroy

	#validates_presence_of :name
	
	def as_json(opts={})
    json = super(opts)
    Hash[*json.map{|k, v| [k, v || ""]}.flatten]
  end

  def self.import(file)
    CSV.foreach(file.path, headers: true) do |row|
      service_category_hash = row.to_hash # exclude the price field
      service_category = ServiceCategory.where(id: service_category_hash["id"])

      if service_category.count == 1
        service_category.first.update_attributes(service_category_hash)
      else
        ServiceCategory.create!(service_category_hash)
      end # end if !service_category.nil?
    end # end CSV.foreach
  end # end self.import(file)

  def self.get_service_categories
    self.select('id,name')
  end

  #def self.import(file)
  #	spreadsheet = open_spreadsheet(file)
  #  header = spreadsheet.row(1)
  #  (2..spreadsheet.last_row).each do |i|
  #  	row = Hash[[header, spreadsheet.row(i)].transpose]
  #  	service_category = find_by_name(row["name"]) || new
  #    if row["name"].present?
  #      service_category.name = row["name"]
  #    end
  #    if row["description"].present?
  #      service_category.description = row["description"]
  #    end
  #  	#product.attributes = row.to_hash.slice(*accessible_attributes)
  #  	service_category.save!
  #	end
  #end	

  #def self.open_spreadsheet(file)
  #	case File.extname(file.original_filename)
  #	when ".csv" then Roo::CSV.new(file.path, {})
  #	when ".xls" then Roo::Excel.new(file.path, {})
  #	when ".xlsx" then Roo::Excelx.new(file.path, {})
  #	else raise "Unknown file type: #{file.original_filename}"
  #	end
	#end
end
