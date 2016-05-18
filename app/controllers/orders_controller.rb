class OrdersController < ApplicationController
	def index
    @orders = Order.all.order("id ASC")
	end
	def new
    @order = Order.new
	end
	def edit
     @order = Order.find(params[:id])
	end
	def create
     @order = Order.new(order_params)    
    respond_to do |format|
      if @order.save
        format.html { redirect_to orders_path, :notice => 'You have successfully created a order' }
        format.xml  { render :xml => @order, :status => :created, :order => @order }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @order.errors, :status => :unprocessable_entity }
      end
    end
	
	end

	def update
    @order = Order.find(params[:id])
    respond_to do |format|
      if @order.update(order_params)
        format.html { redirect_to orders_path, notice: 'You have successfully updated a Order.' }
        format.xml  { render :xml => @order, :status => :created, :order => @order }
      else
        format.html { render :edit }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
		
  	end
  	def destroy
      @order = Order.find(params[:id])
    respond_to do |format|
      if @order.destroy
        format.html { redirect_to orders_path, :notice => 'You have successfully removed a order' }
        format.xml  { render :xml => @order, :status => :created, :order=> @order }
      end
    end
    	
   end

	private
  def order_params
   params.require(:order).permit( :deal_id,:app_user_id,:status,:effective_price,:deal_price,:activation_start_date)
  end
end