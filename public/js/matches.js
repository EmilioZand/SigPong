$(document).ready(function() {

  $.ajax({
    type: "GET",
    url: "api/matches?team_id=59408e751865720006b81b9d",
    success: function(data) {
      var table = $('<table></table>').addClass('table recent-matches');
      var matches = data._embedded.matches
      table.append( '<thead><tr><th>' + 'Winner' + '</th><th>' + 'Loser' + '</th><th>'+ 'Score' + '</th><th>' + "ELO Change" + '</th></tr></thead>' );
      for(var i=0;i<matches.length;i++){
        var match = matches[i];
        var games = match.scores;
        var loserScore = 0;
        var winnerScore = 0;
        var overallScore = "";
        if (games){
          for(var j=0;j<games.length;j++){
            games[j][0] > games[j][1] ? loserScore++ : winnerScore++;
          }
          overallScore = winnerScore + ' : ' + loserScore
        }
        table.append( '<tr><td>' + match.winners[0].user_name + '</td><td>' + match.losers[0].user_name + '</td><td>'+ overallScore + '</td><td>' + (match.elo_change || '') + '</td></tr>' );
      }
      $('#recent-matches').append(table);
    },
  });
});
