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

localDB = (function(){
    'use strict';

    var storage = null;
    try {
        storage = window.localStorage;
        storage.setItem("~~~", "!");
        storage.removeItem("~~~");
    } catch (err) {
        console.log('Local DB not supported!');
        storage = null;
    }

    function store(key, val){
        if(storage){
            storage.setItem(key, JSON.stringify(val));
        }
    }
    function get(key){
        if(storage) {
            return JSON.parse(localStorage.getItem(key));
        }
        return null;
    }
    function remove(key){
        if(storage){
            storage.removeItem(key);
        }
    }

    function clear(){
        if(storage) {
            storage.clear();
        }
    }
    return{
        store: store,
        get: get,
        remove: remove,
        clear: clear,
    }
})();

