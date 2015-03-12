class ServiceProvidersController < ApplicationController
	def index
		@service_providers = ServiceProvider.all
	end
	def new
		@service_provider = ServiceProvider.new
	end
	def show
		@service_provider = ServiceProvider.find(params[:id])
	end
	def edit
		@service_provider = ServiceProvider.find(params[:id])
	end
	def create
		@service_provider = ServiceProvider.new(service_provider_params)    
    	respond_to do |format|
      		if @service_provider.save
        		format.html { redirect_to service_providers_path, :notice => 'You have successfully created a service provider' }
        		format.xml  { render :xml => @service_provider, :status => :created, :service_category => @service_provider }
      		else
        		format.html { render :action => "new" }
        		format.xml  { render :xml => @service_provider.errors, :status => :unprocessable_entity }
      		end
    	end
	end
	def update
		@service_provider = ServiceProvider.find(params[:id])
    	respond_to do |format|
      		if @service_provider.update(service_provider_params)
        		format.html { redirect_to service_providers_path, notice: 'You have successfully updated a Service Provider.' }
        		format.xml  { render :xml => @service_provider, :status => :created, :service_provider => @service_provider }
      		else
        		format.html { render :edit }
        		format.json { render json: @service_provider.errors, status: :unprocessable_entity }
      		end
    	end
	end
	def destroy
		@service_provider = ServiceProvider.find(params[:id])
    	respond_to do |format|
          if @service_provider.destroy
            format.html { redirect_to service_providers_path, :notice => 'You have successfully removed a service provider' }
            format.xml  { render :xml => @service_provider, :status => :created, :service_provider => @service_provider }
          end
    	end	
	end

	private
  	def service_provider_params
  		params.require(:service_provider).permit(:name, :service_category_name, :address, :state, :city, :zip)
  	end
end	