#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

NUMBER_TO_GUESS=$(( RANDOM % 1000 + 1 ))
echo "secret number is $NUMBER_TO_GUESS"

echo "Enter your username: "
read USERNAME
USERDATA_RESULT=$($PSQL "SELECT username, games_played, best_game FROM number_guess WHERE username='$USERNAME'")

if [[ -z $USERDATA_RESULT ]]
then
echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
USER_FIRST_TIME_INSERT=$($PSQL "INSERT INTO number_guess(username, games_played, best_game) VALUES('$USERNAME', 0, 0)")
else
IFS="|" read USERNAME GAMES_PLAYED BEST_GAME <<< "$USERDATA_RESULT"
echo -e "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses." 
fi

#Start the game
echo -e "\nGuess the secret number between 1 and 1000:"
read GUESS
NUMBER_OF_GUESSES=1
#increase the number of games user played
USER_GAME_NUMBER_INCREASE=$($PSQL "UPDATE number_guess SET games_played = ($GAMES_PLAYED + 1) WHERE username = '$USERNAME';")

while ! [[ $GUESS =~ ^[0-9]+$ ]]
do
  echo "That is not an integer, guess again:"
  read GUESS
  $NUMBER_OF_GUESSES+=1
done

while ! [[ $GUESS -eq $NUMBER_TO_GUESS ]]
do
if [[ $GUESS -lt $NUMBER_TO_GUESS ]]
then
echo -e "\nIt's higher than that, guess again:"
read GUESS
(( NUMBER_OF_GUESSES++ ))
elif [[ $GUESS -gt $NUMBER_TO_GUESS ]]
then
echo -e "\nIt's lower than that, guess again:"
read GUESS
(( NUMBER_OF_GUESSES++ ))
fi
done

if [[ $GUESS -eq $NUMBER_TO_GUESS ]]
then
echo -e "\nYou guessed it in $NUMBER_OF_GUESSES tries. The secret number was $NUMBER_TO_GUESS. Nice job!"
if [[ $NUMBER_OF_GUESSES -gt $BEST_GAME ]]
then
INSERT_NEW_BEST=$($PSQL "UPDATE number_guess SET best_game = '$NUMBER_OF_GUESSES' WHERE username = '$USERNAME'")
fi
fi
