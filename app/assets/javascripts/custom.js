$(function(){
    $(document).on("webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend", '.style-msg', function(event) {
        $(this).remove();
    });

    $.Custom = {
        notify: function(message, type = 'successmsg') {
            var floating = $('.floating-notification')
                .append('<div class="style-msg '+type+'">\n' +
                    '<div class="sb-msg">'+message+'</div>' +
                    '<button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>\n' +
                    '</div>');

            $(floating).on('click', '.close', function () {
                $(this).closest('.style-msg').remove();
            });
        }
    }
});

