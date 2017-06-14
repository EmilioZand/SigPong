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
        var eloChange = match.winners[0].elo_history.pop();
        for(score in games){
          score[0] > score[1] ? loserScore++ : winnerScore++;
        }
        var overallScore = winnerScore + ' : ' + loserScore
        table.append( '<tr><td>' + match.winners[0].user_name + '</td><td>' + match.losers[0].user_name + '</td><td>'+ overallScore + '</td><td>' + eloChange + '</td></tr>' );
      }
      $('#recent-matches').append(table);
    },
  });
});
