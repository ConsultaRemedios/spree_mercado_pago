module Spree
  class MercadoPagoController < StoreController

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
          flash.notice = Spree.t(:order_processed_successfully)
          redirect_to order_path(order, token: order.token)
        else
          redirect_to checkout_state_path(order.state)
        end
      end
  end
end
