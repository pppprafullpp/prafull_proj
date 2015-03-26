class Api::V1::CommentsController < ApplicationController
	skip_before_filter :verify_authenticity_token
	respond_to :json

	def index
		@comments = Comment.where("status = ? AND deal_id = ?", true, params[:deal_id])
		if @comments.present?
			render :status => 200,
						 :json => { :success => true,
												:comment => @comments
											}
		else
			render :status => 401,
							:json => { :success => false }
		end	
	end

	def create
		@comment = Comment.new(comment_params) 
      if @comment.save
        render :status => 200,
           		 :json => { :success => true }
      else
        render :status => 401,
           		 :json => { :success => false }
      end
	end

	private
	def comment_params
		params.permit(:app_user_id, :deal_id, :status, :comment_text)
	end
end	