class ServiceProvider < ActiveRecord::Base
	belongs_to :service_category
	has_many :deals, dependent: :destroy

	mount_uploader :logo, ImageUploader
	validates_presence_of :service_category_id, :name, :logo

	def as_json(opts={})
  		json = super(opts)
  		Hash[*json.map{|k, v| [k, v || ""]}.flatten]
	end

	def provider_logo_url
  		logo.url
  end

  def self.import(file)
  	spreadsheet = open_spreadsheet(file)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
    	row = Hash[[header, spreadsheet.row(i)].transpose]
    	service_category = find_by_name(row["name"]) || new
      if row["name"].present?
        service_category.name = row["name"]
      end
      if row["description"].present?
        service_category.description = row["description"]
      end
    	#product.attributes = row.to_hash.slice(*accessible_attributes)
    	service_category.save!
  	end
  end	

  def self.open_spreadsheet(file)
  	case File.extname(file.original_filename)
  	when ".csv" then Roo::CSV.new(file.path, {})
  	when ".xls" then Roo::Excel.new(file.path, {})
  	when ".xlsx" then Roo::Excelx.new(file.path, {})
  	else raise "Unknown file type: #{file.original_filename}"
  	end
	end

end
