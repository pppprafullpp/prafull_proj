class RatingsController < ApplicationController
	def index
		@ratings = Rating.all
	end

	def edit
		@rating = Rating.find(params[:id])
	end

	def update
		@rating = Rating.find(params[:id])
    respond_to do |format|
      if @rating.update(rating_params)
        format.html { redirect_to ratings_path, notice: 'You have successfully updated a Rating.' }
        format.xml  { render :xml => @rating, :status => :created, :rating => @rating }
      else
        format.html { render :edit }
        format.json { render json: @rating.errors, status: :unprocessable_entity }
      end
    end
	end
	def destroy
		@rating = Rating.find(params[:id])
    respond_to do |format|
      if @rating.destroy
        format.html { redirect_to ratings_path, :notice => 'You have successfully removed a rating' }
        format.xml  { render :xml => @rating, :status => :created, :rating => @rating }
      end
    end
	end

	private
	def rating_params
		params.require(:rating).permit(:app_user_id, :deal_id, :rating_point)
	end

end	
