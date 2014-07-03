module Spree
  class MercadoPagoController < StoreController

    def ipn
      notification = gateway.notification(params[:id])

      external_reference = notification["collection"]["external_reference"]

      order_no = external_reference.split('@').first
      order_status = notification["collection"]["status"]
      order = Spree::Order.find_by(number: order_no)

      update_payment_status(order, order_status)

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
      def update_payment_status(order, order_status)
        raise ActionController::RoutingError.new('Not Found') unless order.payments.any?

        payment = order.payments.last

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
        mercado_pago_gateway || create_mercado_pago_gateway
      end

      def create_mercado_pago_gateway
        Spree::PaymentMethod.create({
          type: 'Spree::Gateway::MercadoPago',
          environment: Rails.env,
          name: 'Mercado Pago',
          active: true
        })
      end

      def mercado_pago_gateway
        Spree::PaymentMethod.where(type: 'Spree::Gateway::MercadoPago', environment: Rails.env).first
      end

      def payment_method
        Spree::PaymentMethod.find(params[:payment_method])
      end

      def proccess_order
        order = Spree::Order.by_number(params["order"]).first
        raise(ActiveRecord::RecordNotFound) if order.nil?

        unless order.payments.any?
            order.payments.create!({
            amount: order.total,
            payment_method: payment_method
          })
          order.next
        end

        if order.complete?
          flash[:success] = Spree.t(:order_mp_processed_successfully)
          redirect_to order_path(order, token: order.token)
        else
          redirect_to checkout_state_path(order.state)
        end
      end
  end
end
