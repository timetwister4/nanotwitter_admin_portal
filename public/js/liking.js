 $('a.heart').click(function(){
      $.ajax({
          url: "/tweet/like",
          type: "POST",
          data: {tweet_id: $(this).attr('data-tweet-id')},
          success: function(data){  
              debugger
              if (data != "null"){
                 var likes = $('.heart2').attr('data-tweet-likes')
                 var likes = parseInt(likes) + 1
                 $('.heart2').text(likes.toString())

              }                                   
          } 
  
      })
 })