module Spree
  class MercadoPagoController < StoreController

    def setup
      mp = gateway.provider_class.new(ENV['MERCADO_PAGO_APP_ID'], ENV['MERCADO_PAGO_SECRET_TOKEN'], params[:code])
      auth = mp.authorization_code('http://crteste.ngrok.com/payment/mercardo_pago/setup')

      if auth.has_key?("refresh_token")
        gateway.preferred_authorization_code = params[:code]
        gateway.preferred_refresh_token = auth["refresh_token"]
        gateway.preferred_access_token = auth["access_token"]

        flash[:notice] = "Parabéns! O meio de pagamento Mercado Pago foi vinculado com sucesso a sua loja e está pronto para ser utilizado."
        redirect_to root_path
      else
        render text: auth['message']
      end
    end

    def ipn
      notification = gateway.notification(params[:id])

      order_no = notification["collection"]["external_reference"]
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
        order = current_order || raise(ActiveRecord::RecordNotFound)

        order.payments.create!({
          amount: order.total,
          payment_method: payment_method
        })

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
