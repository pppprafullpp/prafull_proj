/**
 * Created by pandey on 5/29/16.
 */
$( document ).ready(function() {
    $(".comparebox-display").click(function() {
        if ($(".comparebox-display:checkbox:checked").length == 2){
            $("#compare_box").show();
        }
        else if ($(".comparebox-display:checkbox:checked").length != 2){
            $("#compare_box").hide();
        }
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


     $("#zip-code,#first_zip_code,#zip_modal,#zip,#billing_zip,#shipping_zip,#service_zip,#app_user_billing_zip,#app_user_shipping_zip,#app_user_service_zip,#mobile,#business_manager_contact, #contact_number").keydown(function(e)  {
        if ($.inArray(e.keyCode, [46, 8, 9, 27, 13, 110]) !== -1 || (e.keyCode === 65 && (e.ctrlKey === true || e.metaKey === true)) ||(e.keyCode >= 35 && e.keyCode <= 40)) {
          return;
        }
        // Ensure that it is a number and stop the keypress
        if ((e.shiftKey || (e.keyCode < 48 || e.keyCode > 57)) && (e.keyCode < 96 || e.keyCode > 105)) {
          e.preventDefault();
        }
      });

/*
    $('.owl-carousel').owlCarousel({
        loop:true,
        margin:10,
        responsiveClass:true,
        responsive:{
            0:{
                items:1,
                nav:true
            },
            350:{
                items:2,
                nav:true
            },
            450:{
                items:3,
                nav:true
            },
            650:{
                items:4,
                nav:false
            },
            1000:{
                items:6,
                nav:true,
                loop:false
            }
        }
    })
    */


});


