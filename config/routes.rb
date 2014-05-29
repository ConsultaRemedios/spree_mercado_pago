Spree::Core::Engine.routes.draw do

  scope "/payment/mercardo_pago", controller: :mercado_pago do
    get :success, as: :mercado_pago_success
    get :pending, as: :mercado_pago_pending
    get :failure, as: :mercado_pago_failure

    post :ipn, as: :mercado_pago_notification
    get :setup, as: :mercado_pago_setup
  end

end
