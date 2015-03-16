$(document).ready(function(){
    $('input#quantity').on('keyup paste',function(){
        if ($.isNumeric($('input#quantity').val())) {
            $('#cost').text('$'+$('#quantity').val()*10);
        }
        else {
            $('#cost').text('');
        }
    });

    $('form#buy_entries').submit(function() {
        var c = confirm("I agree to pay the " + $('#cost').text() + " entry fee before April 3.");
        return c;
    });
});
