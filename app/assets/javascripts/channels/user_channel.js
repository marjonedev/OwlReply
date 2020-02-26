(function() {
  this.App || (this.App = {});
  App.chat = {};
  App.subscribe_to_channel = function () {
    App.cable.subscriptions.create({channel: "UserChannel"},{
      received: function(data) {
        App.received_data(data);
      }
    });
  }
  App.subscribe_to_channel();
}).call(this);
__data = "";
App.received_data = function (data) {
  __data = data;
  if (data['action'] == "rechecked") {
    $(".last-check").html("Last checked: Less than 1 minute ago.");
  }
  if (data["message"]) {
    $.Custom.notify(data["message"]);
    $(".last-check").html("Last checked: Less than 1 minute ago.");
  }
}