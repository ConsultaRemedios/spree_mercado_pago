Spree::BaseHelper.class_eval do

  def mercado_pago_payment_url_for(payment_method, order)
    back_urls = {
      :success => mercado_pago_success_url(order: order.number, payment_method: payment_method.id),
      :pending => mercado_pago_pending_url(order: order.number, payment_method: payment_method.id),
      :failure => mercado_pago_failure_url(order: order.number, payment_method: payment_method.id)
    }
    payment = payment_method.create_preference(order, back_urls, mercado_pago_notification_url)
    payment['init_point']
  end
end
