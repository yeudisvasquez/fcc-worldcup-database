#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
#clear tables
echo $($PSQL "TRUNCATE games, teams RESTART IDENTITY CASCADE")
#read CSV files
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  #skip files header
  if [[ $YEAR != year ]]
  then
    #insert winner
    INSERT_WINNER=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER') ON CONFLICT (name) DO NOTHING;")
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    if [[ $INSERT_WINNER == "INSERT 0 1" ]]
    then
      echo Inserted into teams, $WINNER
    fi
    #insert opponent
    INSERT_OPPONENT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT') ON CONFLICT (name) DO NOTHING;")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    if [[ $INSERT_OPPONENT == "INSERT 0 1" ]]
    then
      echo Inserted into teams, $OPPONENT
    fi
    #insert games
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    INSERT_GAMES=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS);")
    if [[ $INSERT_GAMES == "INSERT 0 1" ]]
    then
      echo Inserted into games, $ROUND
    fi
  fi
done
