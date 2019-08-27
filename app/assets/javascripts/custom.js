$(function() {
    $('.floating-notification').one('webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend', function() {
        alert('test');
    });
});