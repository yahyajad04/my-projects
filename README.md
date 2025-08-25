# embedded project
tthis project i did using mplab on PIC16F877A

the project simulates a game of escape the room that have 3 challenges you have to win all of the three challenges to win
it waits for the user to press the start button to start the game.

1- first challenge:
once the game started a string of "CHALLENGE 1" will appear on the LCD, then the program will wait for the user to input a number from 0-15 in binary using the 4 switches and press the start button again, the program will see if the user entered a prime number the letter "P" will appear on the 7-seg-display else three dashes will appear under each other and the user will win the challenge if he enters a prime number only.

2- second challenge:
after the first challenge is done now, the second challenge have a potentiometer to change the voltages values, then the user after editing the value presses the start button, if the value is <=25 its correct and a 
string of ‘YOU ARE CORRECT’ will appear on the LCD , if value <=52 its very close and the string ‘YOU ARE CLOSE’ will appear on the LCD and the 
program will wait from the user to change the value another time and press the start button again, else its incorrect and nothing will appear on the LCD 

3- third challenge:
now we are in the las challenge, the challenge consists of 5 simple math problems to solve, after the second challenge is done a string "of challenge 3" will appear then the program will wait as for the previous challenges once the user presses the start button a random problem of the 5 problems will appear on the LCD and a down timer will start from 9-0 on the 7-segment-display, the user should solve the math problem and put the answer using the 4 switches same for challenge 1 and press the finish button before the time runs out to win the challenge else he will lose.

for the challenges there are 3 leds each led will turn on if the user passed the challenge correctly , and if the user passes all the challenges correctly, the leds will start flashing and a String of "YOU WIN!ESCAPE" will appear on the LCD but if he loses in one of them a string of "HARD LUCK" will appear
