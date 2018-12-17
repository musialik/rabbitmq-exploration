class Client::OrdersController < ApplicationController
  def index
    @order = Order.new(location: 'Location A', commodity: 'Commodity A', quantity: 10)
    @orders = Order.all.order(created_at: :desc).limit(20)
    @deliveries = Delivery.includes(:orders).all.order(created_at: :desc).limit(15)
  end

  def create
    @order = Order.new(order_params)

    if @order.save
      EventBus.order_created(@order)
      @order.update!(ack: true)
      head 200
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
