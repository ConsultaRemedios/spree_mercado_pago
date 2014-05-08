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
  }
}

$(document).ready(function() {
  checkedPaymentMethod = $('div[data-hook="checkout_payment_step"] input[type="radio"]:checked');
  SpreeMercadoPago.hidePaymentSaveAndContinueButton(checkedPaymentMethod);
  paymentMethods = $('div[data-hook="checkout_payment_step"] input[type="radio"]').click(function (e) {
    SpreeMercadoPago.hidePaymentSaveAndContinueButton($(e.target));
  });
})
