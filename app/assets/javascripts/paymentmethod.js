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

    form.find('.errormsg').hide();

    //EVERYTHING FROM HERE ON IS PSUEDO CODE
    var expMonthAndYear = form.find('#card_expiration').val().split(" / ");

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

    if (response.error) { // Problem!

        console.log(response);

        $form.find('.errormsg').find('span.message').text(response.error.message);
        $form.find('.errormsg').show();

    } else { // Token was created!

        var token = response.id;
        var def = $form.find('#default').val();
        var data = {
            'token': response.id,
            'card_exp_month': response.card.exp_month,
            'card_exp_year': response.card.exp_year,
            'card_brand': response.card.brand,
            'card_number': response.card.last4,
            'default': def,
        };

        $.put("/paymentmethods", {data: data, onsuccess: Paymentmethod.created, onerror: Paymentmethod.creation_error});
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
    var $form = $("#new_paymentmethod");
    $form.find('.errormsg').find('span.message').text(result);
    $form.find('.errormsg').show();
  //This method should very rarely be called. It means our code refused to save the paymentmethod. Maybe the user got logged out or something.
};
Paymentmethod.created = function (result) {
  //This might actually not do anything.
  //paymentmethods/create.js might do this:
  //$('.popup').remove();
  //$('.paymentmethods').html('<%=j render partial: "paymentmethods/index" %>');
};