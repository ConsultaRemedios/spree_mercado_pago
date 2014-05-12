require 'mercadopago'

module Spree
  class Gateway::MercadoPago < Gateway

    preference :client, :string
    preference :secret, :string
    preference :test_mode, :boolean, default: true

    def source_required?
      false
    end

    def auto_capture?
      false
    end

    def actions
      %w{capture void}
    end

    def can_void?(payment)
      !payment.void?
    end

    def can_capture?(payment)
      payment.pending? || payment.checkout?
    end

    def provider_class
      ::MercadoPago::Client
    end

    def provider
      provider_class.new(preferred_client, preferred_secret)
    end

    def method_type
      'mercado_pago'
    end

    def authorize(amount, source, gateway_options={})
      [amount, checkout, gateway_options].pry
    end

    def capture(a, b, c)
      Class.new do
        def success?; true; end
        def authorization; nil; end
      end.new
    end

    def void(*args)
      ActiveMerchant::Billing::Response.new(true, "", {}, {})
    end

  end
end
