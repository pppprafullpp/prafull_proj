/**
 * Created by pandey on 5/29/16.
 */
$( document ).ready(function() {
    $(".comparebox-display").click(function() {
        $("#compare_box").show();
    });

    $(".close2").click(function() {
        $("#compare_box").hide();
    });

    $(".btn1").click(function() {
        $("#box1").hide();
    });

    $(".btn2").click(function() {
        $("#box2").hide();
    });


    $('#compare_box').affix({
        offset: {
            top: 500
        }
    });
});