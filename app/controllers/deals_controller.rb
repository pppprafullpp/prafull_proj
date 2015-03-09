class DealsController < ApplicationController
	def index
		@deals = Deal.all
	end
	def new
		@deal = Deal.new
	end
	def create
		@deal = Deal.new(deal_params)    
    respond_to do |format|
      if @deal.save
        format.html { redirect_to deals_path, :notice => 'You have successfully created a deal' }
        format.xml  { render :xml => @deal, :status => :created, :deal => @deal }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @deal.errors, :status => :unprocessable_entity }
      end
    end
	end
	def edit
  	@deal = Deal.find(params[:id])
  	#raise @service_deal.inspect
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
  
	private

  def deal_params
  	params.require(:deal).permit(:category, :title, :url, :deal)
  end


end