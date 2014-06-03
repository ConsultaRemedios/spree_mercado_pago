require 'mercadopago'

module Spree
  class Gateway::MercadoPago < Gateway
    include Spree::BaseHelper

    preference :authorization_code, :string
    preference :refresh_token, :string
    preference :access_token, :string

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
      @provider ||= provider_class.new(ENV['MERCADO_PAGO_APP_ID'], ENV['MERCADO_PAGO_SECRET_TOKEN'], preferred_refresh_token)
    end

    def notification(ref)
      notification = provider.notification(ref)

      self.preferred_refresh_token = provider.refresh_token
      self.preferred_access_token = provider.access_token

      self.save!

      notification
    end

    def create_preference(order, back_urls, notification_uri)
      preference = provider.create_preference(payment_preference(order, back_urls, notification_uri))

      self.preferred_refresh_token = provider.refresh_token
      self.preferred_access_token = provider.access_token

      self.save!

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
      # Order Information
      preference[:external_reference] = order.number
      preference[:marketplace_fee] = marketplace_fee(order)
      preference[:back_urls] = back_urls
      preference[:notification_uri] = notification_uri


      payer_date_created = if order.user.nil?
        nil
      else
        order.user.created_at.to_time.iso8601
      end

      # User Information
      preference[:payer] = {
        phone: {
          area_code: order.ship_address.phone.gsub(/\D/,"")[0,2],
          number: order.ship_address.phone.gsub(/\D/,"")[2,9],
        },
        address:{
          zip_code: order.ship_address.zipcode,
          street_name: order.ship_address.address1,
        },
        email: order.user.try(:email),
        name: order.ship_address.firstname,
        surname: order.user.try(:email),
        date_created: payer_date_created
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
          :description => item.product.description
        }
      end

      # Order Adjusts
      if order.adjustment_total.to_f > 0
        preference[:items] << {
          :title => 'Taxas',
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

      preference
    end

    def marketplace_fee(order)
      0.0 unless ENV['MERCADO_PAGO_FEE_PERCENT'].present?
      percent = ENV['MERCADO_PAGO_FEE_PERCENT'].to_f

      (percent / 100.0) * order.total
    end

  end
end
