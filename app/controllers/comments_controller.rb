class CommentsController < ApplicationController
	def index
		@comments = Comment.all
	end
	def edit
		@comment = Comment.find(params[:id])
	end
	def update
		@comment = Comment.find(params[:id])
    respond_to do |format|
      if @comment.update(comment_params)
        format.html { redirect_to comments_path, notice: 'You have successfully updated a Comment.' }
        format.xml  { render :xml => @comment, :status => :created, :comment => @comment }
      else
        format.html { render :edit }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
	end
	def destroy
		@comment = Comment.find(params[:id])
    respond_to do |format|
      if @comment.destroy
        format.html { redirect_to comments_path, :notice => 'You have successfully removed a comment' }
        format.xml  { render :xml => @comment, :status => :created, :comment => @comment }
      end
    end
	end

	private
	def comment_params
		params.require(:comment).permit(:app_user_id, :deal_id, :status, :comment_text)
	end
end	
