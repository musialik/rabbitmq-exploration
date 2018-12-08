class Client::OrdersController < ApplicationController
  def index
    @order = Order.new(location: 'Location A', commodity: 'Commodity A', quantity: 10)
    @orders = Order.all.order(created_at: :desc).limit(20)
    @deliveries = Delivery.includes(:orders).all.order(created_at: :desc).limit(20)
  end

  def create
    @order = Order.new(order_params)

    if @order.save
      Rabbit.publish(@order)
      @order.update!(ack: true)
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
