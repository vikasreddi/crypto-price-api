class PricesController < ApplicationController
  def show
    symbol = params[:symbol].to_s.downcase.strip

    result = PriceResponseService.new(symbol).call

    render json: result[:body], status: result[:status]
  end
end
