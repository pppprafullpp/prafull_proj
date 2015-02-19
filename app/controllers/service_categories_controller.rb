class ServiceCategoriesController < ApplicationController
	def index
		@service_categories = ServiceCategory.all
	end

	def new
		@service_category = ServiceCategory.new
	end

	def create
    @service_category = ServiceCategory.new(service_category_params)    
    respond_to do |format|
      if @service_category.save
        format.html { redirect_to service_category_path, :notice => 'You have successfully created a service category' }
        format.xml  { render :xml => @service_category, :status => :created, :service_category => @service_category }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @service_category.errors, :status => :unprocessable_entity }
      end
    end
  end

  private
  def service_category_params
  	params.require(:service_category).permit(:name)
  end

end