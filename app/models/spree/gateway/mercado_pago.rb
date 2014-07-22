require 'mercadopago'
require 'uri'

module Spree
  class Gateway::MercadoPago < Gateway
    include Spree::BaseHelper

    preference :client_id, :string
    preference :client_secret, :string
    preference :installments, :integer, default: 12

    def source_required?
      false
    end

    def method_type
      'mercado_pago'
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
      @provider ||= provider_class.new(preferred_client_id, preferred_client_secret)
    end

    def notification(ref)
      Rails.logger.info "Enviando notificação: #{ref.inspect}"
      notification = provider.notification(ref)
      Rails.logger.info "Notificação retorno Mercado Pago: #{notification.inspect}"

      notification
    end

    def create_preference(order, back_urls, notification_uri)
      pr = payment_preference(order, back_urls, notification_uri)
      Rails.logger.info "Enviando preferência de pagamento: #{pr.inspect}"
      preference = provider.create_preference(pr)
      Rails.logger.info "Preferência retorno Mercado Pago: #{preference.inspect}"

      preference
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

    private

    def payment_preference(order, back_urls, notification_uri)
      preference = Hash.new

      success_uri = back_urls[:success]
      uri = URI(success_uri)

      external_reference = "#{order.number}@#{uri.host}"

      # Order Information
      preference[:external_reference] = external_reference
      preference[:back_urls] = back_urls
      preference[:notification_uri] = notification_uri

      # MercadoPago asked for it. Do'h!
      preference[:notification_url] = notification_uri

      # User Information
      preference[:payer] = {
        phone: {
          area_code: order.ship_address.phone.gsub(/\D/,"")[0,2],
          number: order.ship_address.phone.gsub(/\D/,"")[2,9],
        },
        address: {
          zip_code: order.ship_address.zipcode,
          street_name: order.ship_address.address1,
        },
        email: order.user.try(:email),
        identification: {
          type: 'CPF',
          number: order.user.document
        },
        name: order.user.first_name,
        surname: order.user.last_name,
        date_created: order.user.created_at.to_time.iso8601
      }

      # Items Information
      preference[:items] = []
      order.line_items.each do |item|
        preference[:items] << {
          :title => item.product.name,
          :unit_price => item.price.to_f,
          :quantity => item.quantity,
          :currency_id => order.currency,
          :picture_url => small_image_url(item.product),
          :description => item.product.description,
          :category_id => 'others'
        }
      end

      # Order Adjusts
      if order.adjustment_total.to_f > 0
        preference[:items] << {
          :title => 'Ajustes',
          :unit_price => order.adjustment_total.to_f,
          :quantity => 1,
          :currency_id => order.currency
        }
      end

      #Shipments Information
      preference[:shipments] = {
        receiver_address: {
          zip_code: order.ship_address.zipcode,
          street_name: order.ship_address.address1,
        }
      }

      # Payment Configuration
      preference[:payment_methods] = {
        installments: preferred_installments
      }

      preference
    end
  end
end
