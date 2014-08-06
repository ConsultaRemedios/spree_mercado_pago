module Spree
  class MercadoPagoController < StoreController

    def ipn
      if params[:topic] == 'payment'
        notification = gateway.notification(params[:id])
        external_reference = notification["collection"]["external_reference"]

        order_no = external_reference.split('@').first
        order_status = notification["collection"]["status"]
        order = Spree::Order.find_by(number: order_no)
        order = go_to_next_step(order)

        update_payment_status(order, order_status)
      end

      render text: "OK"
    end

    def success
      proccess_order
    end

    def pending
      proccess_order
    end

    def failure
      flash[:error] = 'Pagamento recusado, escolha outra forma de efetuar o pagamento.'
      checkout_state_path('payment')
    end

    private

    def go_to_next_step(order)
      if order.payment?
        order.payments.create!({
          :amount => order.total,
          :payment_method => gateway
        })
        order.next
      end
      order
    end

    def update_payment_status(order, order_status)
      payment = order.payments.last
      payment.order = order #payment has old reference from order :/

      case order_status
      when 'approved'
        payment.complete
      when 'pending', 'in_process', 'rejected'
        payment.pend
      when 'refunded', 'cancelled'
        payment.failure
      end
    end

    def gateway
      Spree::PaymentMethod.where(type: 'Spree::Gateway::MercadoPago', environment: Rails.env).first
    end

    def proccess_order
      order = Spree::Order.by_number(params["order"]).first
      raise(ActiveRecord::RecordNotFound) if order.nil?

      order = go_to_next_step(order)
      order.next

      if order.complete?
        flash[:success] = Spree.t(:order_mp_processed_successfully)
        redirect_to order_path(order, token: order.token)
      else
        redirect_to checkout_state_path(order.state)
      end
    end
  end
end
