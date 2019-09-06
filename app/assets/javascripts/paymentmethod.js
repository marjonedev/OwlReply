//EVERYTHING FROM HERE ON IS PROBABLY PSUEDO CODE OR UNTESTED
Paymentmethod = {};
Paymentmethod.set_submit = function () {
  $("#new_paymentmethod").on("submit", function (e) {
      e.preventDefault();

      Paymentmethod.submit_form();

      return false;
  });
};

Paymentmethod.submit_form = function () {

    var form = $("#new_paymentmethod");

    //EVERYTHING FROM HERE ON IS PSUEDO CODE
    var expMonthAndYear = form.find('#card_expiration').val().split(" / ");
    console.log(expMonthAndYear);

    var data = {
        number: form.find('#card_number').val(), //form.closest instead??
        cvc: form.find('#card_cvc').val(),
        exp_month: expMonthAndYear[0],
        exp_year: expMonthAndYear[1]
    };

    Stripe.setPublishableKey('pk_test_JfJHLapqizR8IPrLtem4UXWn00OhqC4dVb');

    Stripe.card.createToken(data, Paymentmethod.ResponseHandler);
    // Stripe.submit(data, {onsuccess: Paymentmethod.stripe_result, onerror: Paymentmethod.stripe_error});
};

Paymentmethod.ResponseHandler = function(status, response) {

    // Grab the form:
    var $form = $("#new_paymentmethod");

    console.log(response);

    if (response.error) { // Problem!

        // Show the errors on the form
        $form.find('.payment-errors').text(response.error.message);
        $form.find('button').prop('disabled', false); // Re-enable submission

    } else { // Token was created!

        // Get the token ID:
        var token = response.id;

        // Insert the token into the form so it gets submitted to the server:
        $form.append($('<input type="hidden" name="paymentmethod[token]" />').val(token));

        // Submit the form:
        // $form.get(0).submit();
    }
};

Paymentmethod.stripe_result = function (result) {
  var token = result.token;
  console.log('token', token);
  $.put("/paymentmethods", {data: {token: token}, onsuccess: Paymentmethod.created, onerror: Paymentmethod.creation_error});

};
Paymentmethod.stripe_error = function (result) {
  $(".new_paymentmethod").prepend("<div class='error'>" + result + "</div>");
};
Paymentmethod.creation_error = function (result) {
  //This method should very rarely be called. It means our code refused to save the paymentmethod. Maybe the user got logged out or something.
  $(".new_paymentmethod").prepend("<div class='error'>" + result + "</div>");
};
Paymentmethod.created = function (result) {
  //This might actually not do anything.
  //paymentmethods/create.js might do this:
  //$('.popup').remove();
  //$('.paymentmethods').html('<%=j render partial: "paymentmethods/index" %>');
};