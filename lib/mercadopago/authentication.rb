module MercadoPago

  module Authentication

    #
    # Receives the client credentials and makes a request to oAuth API.
    # On success, returns a hash with the access data; on failure, returns nil.
    #
    # To get your client credentials, access:
    # https://www.mercadopago.com/mlb/ferramentas/aplicacoes
    #
    # - client_id
    # - client_secret
    #
    def self.access_token(client_id, client_secret, code)
      payload = {
        grant_type: 'authorization_code', client_id: client_id, client_secret: client_secret,
        code: code, redirect_uri: 'http://crteste.ngrok.com/'
      }
      headers = { content_type: 'application/x-www-form-urlencoded', accept: 'application/json' }

      MercadoPago::Request.wrap_post('/oauth/token', payload, headers)
    end

    def self.authorization_code(client_id, client_secret, code, redirect_uri)
      payload = {
        grant_type: 'authorization_code', client_id: client_id, client_secret: client_secret,
        code: code, redirect_uri: redirect_uri
      }
      headers = { content_type: 'application/x-www-form-urlencoded', accept: 'application/json' }

      MercadoPago::Request.wrap_post('/oauth/token', payload, headers)
    end

    #
    # Receives the client credentials and a valid refresh token and requests a new access token.
    #
    # - client_id
    # - client_secret
    # - refresh_token
    #
    def self.refresh_access_token(client_id, client_secret, refresh_token)
      payload = { grant_type: 'refresh_token', client_id: client_id, client_secret: client_secret, refresh_token: refresh_token }
      headers = { content_type: 'application/x-www-form-urlencoded', accept: 'application/json' }

      MercadoPago::Request.wrap_post('/oauth/token', payload, headers)
    end

  end

end
