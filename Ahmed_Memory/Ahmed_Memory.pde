/*
  Memory Game
 by: Ahmed Qazi
 
 Easy - 5 pairs; cardScale-  1.5; AI mem - 3 cards ;show time - 100
 Medium - 9 pairs; cardScale - 1.25; AI mem - 5 cards ; show time - 80
 Hard - 13 pairs ; cardScale - 1.0 ; AI mem - 7 cards; show time - 60
 
 Menu - choose Easy, Medium, Hard
 Game - initialize for Level - shuffle cards
 Draw the level
 Player : pick a card (can't be flipped, can't be gone)
 pick another card
 AI : check for a match in memory
 pick a random card - then check memory
 another random card
 2 cards: Match - take away the matching cards, add to score (AP show match)
 check end
 No match - flip back cards - switch turns
 */
PImage back, back2;
PImage [] cardImg = new PImage [14];
int [] card; //create it at init
boolean [] flipped; //create it at init true=means front of card
int level=0; //0=menu 1=easy 2=med 3=hard 4=game over
float cardScale=1.0;
int showTime=60;
int alarm = -1;
ArrayList <Integer> AImem = new ArrayList(7); //new Data Structure
int turn=0; //0=init 1=player 2=AI
int lastTurn=0;
int [] choice = new int[2];
int select = 0;
ArrayList <Integer> playerPairs = new ArrayList(7);
ArrayList <Integer> AIPairs = new ArrayList(7);
int playerMatches=0;
int AIMatches=0;
String [] mItems = {"Start"};
void setup()
{
  size(1000, 800);
  //read in cards && card back
  back  = loadImage("BACK.jpg");
  back2 = loadImage("back2.jpg");
  cardImg[0] = loadImage("green_back.png");
  for (int i=1; i<14; i++)
    cardImg[i]= loadImage(i+"H.png");
}
void draw()
{
  if (level ==0)
    showMenu();
  if (level == 3)
  {
    if (turn==0)
      initCards();
    if (turn==2)
      AITurn();
    if (turn==3)
      cardMatch();
    showCards();
    if (turn ==4)
      showEnd();
  }
}
void mousePressed()
{
  if (level==0)
    menu();
  if (mouseX<20 && mouseY<20)
    turn=0;
  if (turn==1)
    playerTurn();
}
void initCards()
{
  AImem.clear();
  AIPairs.clear();
  playerPairs.clear();
  if (level ==3)
  {
    card = new int[26];
    for (int i=0; i<card.length; i++)
      card[i] = (i%13)+1;
    flipped = new boolean[26];
    for (int i=0; i<flipped.length; i++)
      flipped[i] = false;
    shuffleCards();
  }
  turn=2;
}
void showCards()
{
  image(back2, 0, 0, width, height);
  textSize(30);
  text("Player", 60, 90);
  text("AI", 850, 90);
  for (int i=0; i<card.length; i++)
  {
    if (flipped[i])
    {
      if (card[i] > 0)
        image(cardImg[card[i]], 200+100*(i%6), 120+120*(i/6), 80, 100);
    } else
      image(cardImg[0], 200+100*(i%6), 120+120*(i/6), 80, 100);
  }
  for (int i=0; i<playerPairs.size(); i++)
  {
    image(cardImg[playerPairs.get(i)], 20, 120+ 60*(i), 80, 100);
    image(cardImg[playerPairs.get(i)], 20+20, 120+ 60*(i)+20, 80, 100);
  }
  for (int i=0; i<AIPairs.size(); i++)
  {
    image(cardImg[AIPairs.get(i)], 820, 120+ 60*(i), 80, 100);
    image(cardImg[AIPairs.get(i)], 820+20, 120+ 60*(i)+20, 80, 100);
  }
}
void showEnd()
{
  textSize(40);
  if (playerPairs.size() > AIPairs.size())
    text("nice", 400, 400);
  else
    text("how did you lose what", 400, 400);
}
void playerTurn()
{
  for (int i=0; i<card.length; i++)
  {
    if (!flipped[i] && mouseX>200+100*(i%6)  && mouseX<200+100*(i%6)+80
      && mouseY>120+120*(i/6) && mouseY<120+120*(i/6)+100 )
    {
      flipped[i] = true;
      choice[select] = i;
      select++;
      if (select==2)
        cardMatch();
    }
  }
}
void AITurn()
{
  if (alarm == -1) // pick 2 cards and show the first card
  {
    alarm = showTime;
    //our first check is to find a match in memory
    for (int i=0; i<AImem.size()-1; i++)
    {
      for (int j=i+1; j<AImem.size(); j++)
      {
        if (card[AImem.get(i)]==card[AImem.get(j)])
        {
          choice[0] = AImem.get(i);
          choice[1] = AImem.get(j);
          select=2;
        }
      }
    }
    while (select != 2)
    {
      int ran = (int)random(card.length);
      if (!flipped[ran] && (select != 1 || choice[0] != ran))
      {
        choice[select] = ran;
        select++;
      }
    }
    flipped [choice[0]] = true;
  }
  alarm --;
  if (alarm==0)
  {
    flipped [choice[1]] = true;
    alarm=-1;
    cardMatch();
  }
}
void cardMatch()
{

  if (alarm == -1)
  {
    alarm = showTime;
    lastTurn=turn;
    turn=3;
  }
  alarm --;

  if (alarm==0)
  {
    //if cards in choice match - remove cards, add to score
    if (card[choice[0]] == card[choice[1]])
    {
      if (lastTurn==1)
        playerPairs.add(card[choice[0]]);
      else
        AIPairs.add(card[choice[0]]);
      card[choice[0]]=-1;
      card[choice[1]]=-1;
      if (card.length/2 == playerPairs.size() + AIPairs.size())
        turn=4;
      forget();
    }
    //no match - flip cards back
    else
    {
      flipped[choice[0]]=false;
      flipped[choice[1]]=false;
      forget();
      AImem.add(choice[0]);
      AImem.add(choice[1]);
    }
    //change turns
    select=0;
    if (lastTurn==1 && turn!=4)
      turn=2;
    if (lastTurn==2 && turn!=4)
      turn=1;
    alarm = -1;
    for (int x : AImem)
    {
      print(x+" ");
    }
    println();
  }
}
void forget()
{
  for (int i=0; i<AImem.size(); i++)
  {
    if (AImem.get(i)== choice[0] || AImem.get(i)== choice[1])
    {
      AImem.remove(i);
      i--;
    }
  }
}
void shuffleCards()
{
  int r1, r2, temp;
  for (int i=0; i<card.length; i++)
  {
    r1 = (int)random(card.length);
    r2 = (int)random(card.length);
    temp = card[r1];
    card[r1] = card[r2];
    card[r2] = temp;
  }
}
void showMenu()
{
  image(back, 0, 0, width, height);
  textSize(30);
  for (int i=0; i<1; i++)
  {
    if (mouseX>400 && mouseX <400+200
      && mouseY>150+i*90 && mouseY<150+i*90+50)
      fill(#E30E0E);
    else fill(#081DFC);
    rect(400, 150+i*90, 200, 60, 100);
    fill(255);
    text(mItems[i], 415, 185+i*90);
  }
}
void menu()
{
  for (int i=0; i<1; i++)
  {
    if (mouseX>400 && mouseX <400+200
      && mouseY>150+i*60 && mouseY< 150+i*60+50 )
    {
      level = i+3;
      turn=0;
    }
  }
}
