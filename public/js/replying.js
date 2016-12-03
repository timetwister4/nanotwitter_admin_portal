$('a.reply').click(function(){
    $.ajax({
        url: "/tweet/replies",
        type: "GET",
        data: {tweet_id: $(this).attr('data-tweet-id')},
        success: function(data){
          var input = JSON.parse(data)
          var tweet_id = input["id"]
          if (input["replies"].length == 0) {
              $('#footer').append('<h4> Tweet has no responses, be the first </h4>')                            
          }else{

             var replies =  reparse_input(input["replies"])
             for (i= 0; i< replies.length; i++){
                var tweet = replies[i]
                $('#footer').append('<div class="panel panel-default"> <div class="panel panel-heading"> '+ tweet.author_name +'tweeted at' + tweet.created_at + '</div> <div class ="panel panel-body">' + tweet.text + ' </div> </div>')

              }

              $('#footer').append('<form action="/tweet/reply/'+ tweet_id +'" method="POST"> <div class="form-group" id="comment"> <label for="RoarInput">Roar!</label> <textarea type=text class="form-control" name= "tweet_text" id="Tweet_input"> </textarea> </div> <button type="submit" class="btn btn-default">Submit</button> </form>')
          }                        
          


      }
   })
})

        //as the javascript JSON.parse does not return a javascript hash object directly (but an array with the hashes represented in a string) The following function parses the result of JSON.parse to produce an array "replies" of javascript hashes where the information of the tweets can be accesses by doing replies["keyword"] (where keyword would be "text", "id", "authonr_name" ect)

function reparse_input(input){
  replies = [] 
  for (i= 0; i< input.length; i++) {
       var hash = {}
       var str = input[i].substring(1,input[i].length-1)
       var str =  str + ',' //so that we cut the first                         
       while (str.length != 0){  
          if (str.charAt(str.indexOf(':')+1) == '"'){
            hash[str.substring(1,str.indexOf(':')-1)] = str.substring(str.indexOf(':')+2, str.indexOf(',')-1)
          } else {
            hash[str.substring(1,str.indexOf(':')-1)] = str.substring(str.indexOf(':')+1, str.indexOf(','))
          }
          str = str.substring(str.indexOf(',')+1, str.length)
                                     
       }

       replies.push(hash)
  }

  return replies
              
}
