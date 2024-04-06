#!/bin/bash

# variable to query database
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# generate random number between 1 and 1000
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
# Store number of guesses
GUESS_COUNT=0

#Get user's name
echo "Enter your username:"
read USERNAME

# Query database for Username and User ID
USERNAME_RESULT=$($PSQL "SELECT username FROM users WHERE username='$USERNAME'")
# get user id
USER_ID_RESULT=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME_RESULT'")

# Username not found
if [[ -z $USERNAME_RESULT ]]
  then
    echo "Welcome, $USERNAME! It looks like this is your first time here."
    # Insert New Username into table
      INSERT_USERNAME_RESULT=$($PSQL "INSERT INTO users(username) VALUES ('$USERNAME')")
  else
    #Query database for Games Played and Best Game
    GAMES_PLAYED=$($PSQL "SELECT COUNT(game_id) FROM games LEFT JOIN users USING(user_id) WHERE username='$USERNAME'")
    BEST_GAME=$($PSQL "SELECT MIN(number_of_guesses) FROM games LEFT JOIN users USING(user_id) WHERE username='$USERNAME'")

    echo Welcome back, $USERNAME\! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.
fi

# Ask for first guess
echo "Guess the secret number between 1 and 1000:"
read USER_GUESS


# Look Until Guess = Secret
  until [[ $USER_GUESS == $SECRET_NUMBER ]]
    do
# Is guess a number?
    if [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
      then
        echo -e "\nThat is not an integer, guess again:"
        read USER_GUESS
        ((GUESS_COUNT++))
    
# Valid Number, Lower or Higher?
    else
#Less Than Secret Number
      if [[ $USER_GUESS < $SECRET_NUMBER ]]
        then
          echo "It's higher than that, guess again:"
          read USER_GUESS
          ((GUESS_COUNT++))
        else 
          echo "It's lower than that, guess again:"
          read USER_GUESS
          ((GUESS_COUNT++))
      fi  
    fi
  done

((GUESS_COUNT++))

USER_ID_RESULT=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
echo You guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job\!
INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, secret_number, number_of_guesses) VALUES ($USER_ID_RESULT, $SECRET_NUMBER, $GUESS_COUNT)")
