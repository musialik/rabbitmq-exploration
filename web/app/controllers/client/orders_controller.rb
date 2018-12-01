class Client::OrdersController < ApplicationController
  def index
    @order = Order.new
    @orders = Order.all
  end

  def create
    @order = Order.new(order_params)

    if @order.save
      redirect_to client_orders_path, notice: 'Order placed'
    else
      @orders = Order.all
      render :index
    end
  end

  private

  def order_params
    params.require(:order).permit(:location, :quantity, :commodity)
  end
end
