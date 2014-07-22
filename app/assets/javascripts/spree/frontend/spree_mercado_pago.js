paymentReturn = function(json){
  if(json.back_url != null){
    window.location = json.back_url
  }
}

SpreeMercadoPago = {
  hidePaymentSaveAndContinueButton: function(paymentMethod) {
    if (SpreeMercadoPago.paymentMethodID && paymentMethod.val() == SpreeMercadoPago.paymentMethodID) {
      $('.continue').hide();
    } else {
      $('.continue').show();
    }
  },
  showMercadoPagoBanner: function(paymentMethod) {
    var banner = $('p#mercado_pago_banner').clone().show();
    if (SpreeMercadoPago.paymentMethodID && paymentMethod.val() == SpreeMercadoPago.paymentMethodID) {
      $('#checkout-summary #mercado_pago_banner').remove();
      $('#checkout-summary').append(banner);
    } else {
      $('#checkout-summary #mercado_pago_banner').remove();
    }
  }
}

$(document).ready(function() {
  checkedPaymentMethod = $('div[data-hook="checkout_payment_step"] input[type="radio"]:checked');
  SpreeMercadoPago.hidePaymentSaveAndContinueButton(checkedPaymentMethod);
  paymentMethods = $('div[data-hook="checkout_payment_step"] input[type="radio"]').click(function (e) {
    SpreeMercadoPago.hidePaymentSaveAndContinueButton($(e.target));
    SpreeMercadoPago.showMercadoPagoBanner($(e.target));
  });
})
