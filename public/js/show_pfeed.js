      $(document).ready(function(){
        $("#ShowTweets").click(function(){
          var url = "api/v1/users/" + document.getElementById("user_name").innerHTML + "/tweets";
          //$("#TESTSECTION").empty().append("JQuery is working");
          $.post(url, function(result){
            var tweets = JSON.parse(result);
            $("#tweet_feed").html("Your Tweets: <br>");
            for(i = 0; i<tweets.length; i++){
              t = tweets[tweets.length-i-1];
              $("#tweet_feed").append(
                "<div class='panel panel-deault'>\n<div class = 'panel panel-heading'>\n" +
                 t.author_name + " tweeted at " + t.created_at + ":\n</div>" +
                 "<div class='panel panel-body'>\n" + t.text +"\n</div>\n</div>\n<br>");
               };
          //  $("#tweet_feed").html(tweets[1].text);
        	});
    	});
 	 });
