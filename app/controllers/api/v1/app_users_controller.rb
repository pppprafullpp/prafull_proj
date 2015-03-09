class Api::V1::AppUsersController < ApplicationController
	skip_before_filter :verify_authenticity_token
	respond_to :json

	def new
		@app_user = AppUser.new
	end

	def create
		@app_user = AppUser.find_by_id(params[:id])
		if @app_user.present?
			if @app_user.update(app_user_params)
        		#format.json { success: :true }
        		render :status => 200,
           			:json => { :success => true }
      		else
        		render :status => 401,
           		:json => { :success => false }	
        	end
		else
			@app_user = AppUser.new(app_user_params) 
			#raise service_preference_params.inspect   
    		#respond_to do |format|
      		if @app_user.save
      			#format.json { render json: @service_preference, status: :created }
        		#format.xml { render xml: @service_preference, status: :created }
        		render :status => 200,
           		:json => { :success => true }
      		else
        		#format.json { render json: @user.errors}
        		render :status => 401,
           		:json => { :success => false }
      		end
    		#end
		end	
	end

	private
	def app_user_params
		params.permit(:first_name, :last_name, :email, :state, :city, :zip, :password)
	end

end	