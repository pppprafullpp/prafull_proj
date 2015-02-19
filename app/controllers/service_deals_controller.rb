class ServiceDealsController < ApplicationController
	def index
		@service_deals = ServiceDeal.all
	end
	def new
		@service_deal = ServiceDeal.new
	end
	def create
		@service_deal = ServiceDeal.new(service_deal_params)    
    respond_to do |format|
      if @service_deal.save
        format.html { redirect_to service_deals_path, :notice => 'You have successfully created a service deal' }
        format.xml  { render :xml => @service_deal, :status => :created, :service_deal => @service_deal }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @service_deal.errors, :status => :unprocessable_entity }
      end
    end
	end
	def edit
  	@service_deal = ServiceDeal.find(params[:id])
  	#raise @service_deal.inspect
  end
	def update
		@service_deal = ServiceDeal.find(params[:id])
    respond_to do |format|
      if @service_deal.update(service_deal_params)
        format.html { redirect_to service_deals_path, notice: 'You have successfully updated a Deal.' }
        format.xml  { render :xml => @service_deal, :status => :created, :service_deal => @service_deal }
      else
        format.html { render :edit }
        format.json { render json: @service_deal.errors, status: :unprocessable_entity }
      end
    end
  end
  
	private

  def service_deal_params
  	params.require(:service_deal).permit(:category, :company, :state, :zip, :deal)
  end


end