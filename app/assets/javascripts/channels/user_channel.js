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
App.received_data = function (data) {
  if (data['action'] == "rechecked") {
    //$(".check_status").html("Last checked: Less than 1 minute ago.");
  }
  if (data["message"]) {
    //popup_message(data["message"]);
    //Needs defined.
  }
}