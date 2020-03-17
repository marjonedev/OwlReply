(function() {

    this.App || (this.App = {});
    App.chat = {};

    App.subscribe_to_channel = function () {
        var account = $('meta[name=emailaccount]');
        if(account.length > 0){
            acc_id = $(account).attr('content');
            App.cable.subscriptions.create({channel: "EmailaccountChannel", id: acc_id},{
                received: function(data) {
                    if(data['last_checked']){
                        let last_check = $('span.last-check');
                        if(last_check.length > 0){
                            $(last_check).text(data['last_checked']);
                        }
                    }
                }
            });
        }
    };

    App.subscribe_to_channel();

}).call(this);