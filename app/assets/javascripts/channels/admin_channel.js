(function() {
    this.App || (this.App = {});
    App.chat = {};

    function trim_notif_box(){
        let notif = $('#checked-notification').find('li');
        if(notif.size() > 2){
            notif.last().remove();
        }
    }
    function prepend_checked_update(notif){
        trim_notif_box();
        let str = '<li class="list-group-item">'+notif+'</li>';
        $('#checked-notification').find('ul').prepend(str);
    }

    App.subscribe_to_channel = function () {
        App.cable.subscriptions.create({channel: "AdminChannel"},{
            received: function(data) {
                if(data['last_checked']){
                    $('span.admin_last_checked').text(data['last_checked'])
                }

                if(data['rm_running']){
                    $('span.admin_rm_running').text(data['rm_running'])
                }

                if(data['checked_update']){
                    prepend_checked_update(data['checked_update']);
                }
            }
        });
    };
    App.subscribe_to_channel();

}).call(this);