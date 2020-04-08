(function() {
  this.App || (this.App = {});
  App.chat = {};
  App.subscribe_to_channel = function () {
    App.cable.subscriptions.create({channel: "UserChannel"},{
      received: function(data) {
        App.received_data(data);
      }
    });
  };
  App.subscribe_to_channel();
}).call(this);
__data = "";
App.received_data = function (data) {
  if (data["message"]) {
    $.Custom.notify(data["message"]);
  }
};