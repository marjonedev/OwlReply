$(function(){
    $(document).on("webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend", '.style-msg', function(event) {
        $(this).remove();
    });
});

