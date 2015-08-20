class DealsController < ApplicationController

	def index
		@deals = Deal.all
	end

	def new
		@deal = Deal.new
    
	end
  
  def get_service_providers
    #@ServiceProviders=ServiceProvider.select("id, name").where(service_category_name: params[:category])
    @ServiceProviders=ServiceProvider.select("id, name").where(service_category_id: params[:category])
    render :json => @ServiceProviders
  end

	def create
		@deal = Deal.new(deal_params)    
    respond_to do |format|
      if @deal.save
        format.html { redirect_to deals_path, :notice => 'You have successfully created a deal' }
        format.xml  { render :xml => @deal, :status => :created, :deal => @deal }
      else
        #raise @deal.errors.inspect
        format.html { render :action => "new" }
        format.json  { render :json => @deal.errors, :status => :unprocessable_entity }
      end
    end
	end
	def edit
  	@deal = Deal.find(params[:id])
  end
	def update
		@deal = Deal.find(params[:id])
    respond_to do |format|
      if @deal.update(deal_params)
        format.html { redirect_to deals_path, notice: 'You have successfully updated a Deal.' }
        format.xml  { render :xml => @deal, :status => :created, :deal => @deal }
      else
        format.html { render :edit }
        format.json { render json: @deal.errors, status: :unprocessable_entity }
      end
    end
  end
  def destroy
    @deal = Deal.find(params[:id])
    respond_to do |format|
          if @deal.destroy
            format.html { redirect_to deals_path, :notice => 'You have successfully removed a deal' }
            format.xml  { render :xml => @deal, :status => :created, :deal => @deal }
          end
    end
  end
  
	private

  def deal_params
  	params.require(:deal).permit(:service_category_id, :service_provider_id, :service_category_name, :service_provider_name, :title, :state, :city, :zip, :short_description, :detail_description, :price, :url, :you_save_text, :start_date, :end_date, :image, :is_active)
  end

  

end