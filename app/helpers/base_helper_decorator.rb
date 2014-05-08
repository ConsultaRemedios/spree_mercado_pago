Spree::BaseHelper.class_eval do

  def mercado_pago_payment_url_for(payment_method, order)
    @order = order

    mp_client = payment_method.provider

    payment = mp_client.create_preference payment_preference(payment_method)

    payment['sandbox_init_point']
  end

  private
    def payment_preference(payment_method)
      preference = Hash.new
      preference[:external_reference] = @order.number
      preference[:back_urls] = {
        :success => mercado_pago_success_url(order: @order.number, payment_method: payment_method.id),
        :pending => mercado_pago_pending_url(order: @order.number, payment_method: payment_method.id),
        :failure => mercado_pago_failure_url(order: @order.number, payment_method: payment_method.id)
      }

      preference[:items] = []

      @order.line_items.each do |item|
        preference[:items] << {
          :title => item.product.name,
          :unit_price => item.price.to_f,
          :quantity => item.quantity,
          :currency_id => item.order.currency
        }
      end

      preference
    end
end
