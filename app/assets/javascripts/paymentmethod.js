//EVERYTHING FROM HERE ON IS PROBABLY PSUEDO CODE OR UNTESTED
Paymentmethod = {};
Paymentmethod.set_submit = function () {
  $(".new_paymentmethod").on("submit", function (e) {
      e.preventDefault();
      Paymentmethod.submit_form();
  });
}
Paymentmethod.submit_form = function (e) {
  var form = $(e.target);

  //EVERYTHING FROM HERE ON IS PSUEDO CODE
  data = {
    card_number: form.find('#card_number'), //form.closest instead??
    exp_month: form.find('#card_exp_month'),
    exp_year: form.find('#card_exp_year')
  };

  var stripe = Stripe('pk_test_JfJHLapqizR8IPrLtem4UXWn00OhqC4dVb');
  var elements = stripe.elements();
  console.log(elements);
  // Stripe.submit(data, {onsuccess: Paymentmethod.stripe_result, onerror: Paymentmethod.stripe_error});

}
Paymentmethod.stripe_result = function (result) {
  var token = result.token;
  console.log('token', token);
  $.put("/paymentmethods", {data: {token: token}, onsuccess: Paymentmethod.created, onerror: Paymentmethod.creation_error});

}
Paymentmethod.stripe_error = function (result) {
  $(".new_paymentmethod").prepend("<div class='error'>" + result + "</div>");
}
Paymentmethod.creation_error = function (result) {
  //This method should very rarely be called. It means our code refused to save the paymentmethod. Maybe the user got logged out or something.
  $(".new_paymentmethod").prepend("<div class='error'>" + result + "</div>");
}
Paymentmethod.created = function (result) {
  //This might actually not do anything.
  //paymentmethods/create.js might do this:
  //$('.popup').remove();
  //$('.paymentmethods').html('<%=j render partial: "paymentmethods/index" %>');
}