(function() {
    this.App || (this.App = {});
    App.chat = {};

    App.subscribe_to_channel = function () {
        App.cable.subscriptions.create({channel: "AdminChannel"},{
            received: function(data) {
                if(data['last_checked']){
                    $('span.admin_last_checked').text(data['last_checked'])
                }

                if(data['rm_running']){
                    $('span.admin_rm_running').text(data['rm_running'])
                }
            }
        });
    };
    App.subscribe_to_channel();

}).call(this);