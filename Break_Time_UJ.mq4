//+------------------------------------------------------------------+
//|                                                   Break_Time.mq4 |
//|                              Copyright 2013, robinoud-investment |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, robinoud-investment"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
   extern string TradeTime = "02:00:00";
   extern int Offset = 0;
   
   double PriceHight;
   double PriceLow; 
   string CurrentTime;
   string BarTime;
   double EMA60;
   double lot = 0.01;
   int ticket;
   bool BuyCon1, BuyCon2, BuyCon3;
   int Last_Bar=0;
   int Last_Bar_Buy=0;
   int Last_Bar_Sell=0;
   double Reward = 1.5;
   int Magic = 1234;
   int PriceRange = 250;
   double PriceFrom;
   double PriceTo;   
   int Last_DD = 0;
   int Last_MM = 0;
   int Last_YY = 0;
   

   
int OnInit()
  {
//---

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   TraillingStop();
   //Comment(Last_DD+"/"+Last_MM+"/"+Last_YY + " -- "+Day()+"/"+Month()+"/"+Year());
   if(Last_DD != Day() || Last_MM != Month() || Last_YY != Year())

   {
      BreakTime();
      DeleteOrder2();

// Open Order
      if(BuyCon1 && BuyCon2)
      {
         if(Last_Bar != Bars )
         {
            DeleteOrder();
            OpenOrder();
         }
      }
   }

  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void BreakTime()
  {
  
      
      PriceHight = iCustom(NULL,PERIOD_CURRENT,"BreakOut_PANCA_EAGLE__indicator",1,1);
      PriceLow = iCustom(NULL,PERIOD_CURRENT,"BreakOut_PANCA_EAGLE__indicator",2,1);
      BarTime = TimeToStr(iTime(NULL,PERIOD_CURRENT,0),TIME_SECONDS);
      EMA60 = iMA(NULL,PERIOD_CURRENT,60,0,MODE_EMA,PRICE_CLOSE,1);
        
   
      if(PriceHight != EMPTY_VALUE)
      {
         BuyCon1 = True; 
      }else{
         BuyCon1 = False;
      }
  
      if(BarTime > TradeTime)
      {
         BuyCon2 = True;
      }else{
         BuyCon2 = False;
      } 

  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------+  
 void OpenOrder()
  {
   double WKPriceHight;
   double WKPriceLow;
   double Distance;
   int i_BarL;
   int i_BarH;
   double L52Price;
   double H52Price;
   
   i_BarL = iLowest(NULL,PERIOD_W1,MODE_LOW,200,0);
   L52Price = iLow(NULL,PERIOD_W1,i_BarL)+500*Point; 
   i_BarH = iHighest(NULL,PERIOD_W1,MODE_HIGH,200,0);
   H52Price = iHigh(NULL,PERIOD_W1,i_BarH)-500*Point;
   
   WKPriceHight = PriceHight + Offset*Point;
   WKPriceLow = PriceLow - Offset*Point;
   Distance = (WKPriceHight - WKPriceLow)*1/Point ;
   
   //Comment(WKPriceHight+" / "+WKPriceLow + " / "+Distance);
   //Comment("Bar_H : " + i_BarH + " Bar L : " + i_BarL);
   
 // Pending buy and sell
   if(PriceHight >= EMA60 && PriceLow <=EMA60)
   {
   //Comment("Pending BUY and SELL");
      if(Ask <= PriceHight)
      {  
         ChkOrderBuy(WKPriceHight);
         if(BuyCon3 && Last_Bar_Buy != Bars && i_BarL >= 50)
         {     
            ticket=OrderSend(NULL,OP_BUYSTOP,lot,WKPriceHight,3,L52Price,WKPriceHight+(Distance*Reward)*Point,"",Year()*10000+Month()*100+Day(),0,clrNONE);         
            if(ticket > 0)
            {
               Last_Bar_Buy=Bars;
               //Last_DD = Day();
               //Last_MM = Month();
               //Last_YY = Year();
               //return;
            }else{
               Print("Error BUYSTOP : ",GetLastError());
               //return;
            }
          }
      }else{
         ChkOrderBuy(WKPriceHight);
         if(BuyCon3 && Last_Bar_Buy != Bars && i_BarL >= 50)
         {
               ticket=OrderSend(NULL,OP_BUYLIMIT,lot,WKPriceHight,3,L52Price,WKPriceHight+(Distance*Reward)*Point,"",Year()*10000+Month()*100+Day(),0,clrNONE);
               if(ticket > 0)
               {
                  Last_Bar_Buy=Bars;
                  //Last_DD = Day();
                  //Last_MM = Month();
                  //Last_YY = Year();
                  //return;
               }else{
                  Print("Error BUYLIMIT : ",GetLastError());
                  //return;
               }
         }         
     }
      
      if(Bid >= PriceLow)
      {
         ChkOrderSell(WKPriceLow);
         if(BuyCon3 && Last_Bar_Sell != Bars && i_BarH >= 50)
         {
               ticket=OrderSend(NULL,OP_SELLSTOP,lot,WKPriceLow,3,H52Price,WKPriceLow-(Distance*Reward)*Point,"",Year()*10000+Month()*100+Day(),0,clrNONE);
       
               if(ticket > 0)
               {
                  Last_Bar_Sell=Bars;
                  //Last_DD = Day();
                  //Last_MM = Month();
                  //Last_YY = Year();
                  //return;
               }else{
                  Print("Error SELL STOP : ",GetLastError());
                  //return;
               }
         }       
      }else{
         ChkOrderSell(WKPriceLow);
         if(BuyCon3 && Last_Bar_Sell != Bars && i_BarH >= 50)
         {
               ticket=OrderSend(NULL,OP_SELLLIMIT,lot,WKPriceLow,3,H52Price,WKPriceLow -(Distance*Reward)*Point,"",Year()*10000+Month()*100+Day(),0,clrNONE);   
               if(ticket > 0)
               {
                  Last_Bar_Sell=Bars;
                  //Last_DD = Day();
                  //Last_MM = Month();
                  //Last_YY = Year();
                  //return;
               }else{
                  Print("Error SELL LIMIT : ",GetLastError());
                  //return;
               }
          }
      }
      if(Last_Bar_Buy==Last_Bar_Sell==Bars)
      {
         Last_Bar=Bars;
         Last_DD = Day();
         Last_MM = Month();
         Last_YY = Year();
         return;
      }
    }

//----------------------------------------------------------------------------------------
      // Pending Buy
   if(PriceHight >= EMA60 && PriceLow >=EMA60)
   {
   //Comment("Pending BUY");
      if(Ask <= PriceHight)
      {
         ChkOrderBuy(WKPriceHight);
         if(BuyCon3 && i_BarL >= 50)
         {
               ticket=OrderSend(NULL,OP_BUYSTOP,lot,WKPriceHight,3,L52Price,WKPriceHight+(Distance*Reward)*Point,"",Magic,0,clrNONE);         
               if(ticket > 0)
               {
                  Last_Bar=Bars;
                  Last_DD = Day();
                  Last_MM = Month();
                  Last_YY = Year();
                  return;
               }else{
                  Print("Error BUYSTOP : ",GetLastError());
                  return;
               }
          }
        
      }else{
         ChkOrderBuy(WKPriceHight);
         if(BuyCon3 && i_BarL >= 50)
         {
               ticket=OrderSend(NULL,OP_BUYLIMIT,lot,WKPriceHight,3,L52Price,WKPriceHight+(Distance*Reward)*Point,"",Magic,0,clrNONE);
               if(ticket > 0)
               {
                  Last_Bar=Bars;
                  Last_DD = Day();
                  Last_MM = Month();
                  Last_YY = Year();
                  return;
               }else{
                  Print("Error BUYLIMIT : ",GetLastError());
                  return;
               }
          }
      }
   }
//-------------------------------------------------------------------------------------------
// Pending Sell
   if(PriceHight <= EMA60 && PriceLow <=EMA60)
   {
   //Comment("Pending SELL");
      if(Bid >= PriceLow)
      {
         
         ChkOrderSell(WKPriceLow);
         if(BuyCon3 && i_BarH >= 50)
         {
            
            ticket=OrderSend(NULL,OP_SELLSTOP,lot,WKPriceLow,3,H52Price,WKPriceLow-(Distance*Reward)*Point,"",Magic,0,clrNONE);    
            if(ticket > 0)
            {
               Last_Bar=Bars;
               Last_DD = Day();
               Last_MM = Month();
               Last_YY = Year();
               return;
            }else{
               Print("Error SELLSTOP : ",GetLastError());
               return;
            }
          }
      }else{
         ChkOrderSell(WKPriceLow);
         if(BuyCon3 && i_BarH >= 50)
         {
               ticket=OrderSend(NULL,OP_SELLLIMIT,lot,WKPriceLow,3,H52Price,WKPriceLow -(Distance*Reward)*Point,"",Magic,0,clrNONE);
               if(ticket > 0)
               {
                  Last_Bar=Bars;
                  Last_DD = Day();
                  Last_MM = Month();
                  Last_YY = Year();
                  return;
               }else{
                  Print("Error SELLLIMIT : ",GetLastError());
                  return;
               }
          }
      }
   }
  }
  //+---------------------------------------------------------------------------------------------------------------------------------------------------------------------+  
 void DeleteOrder()
  {
//---
   for(int i = OrdersTotal()-1;i>=0;i--)
   {
     ticket=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
     if(OrderType() != OP_BUY && OrderType() != OP_SELL && OrderMagicNumber() == Magic)
      {  
        ticket=OrderDelete(OrderTicket(),clrNONE);
      }
   }
  }
  //+---------------------------------------------------------------------------------------------------------------------------------------------------------------------+
 void DeleteOrder2()
  {
//---
   int Magic2 = 0;

  
   for(int i = OrdersTotal()-1;i>=0;i--)
   {
        ticket=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
        if(OrderType() == OP_SELL || OrderType() == OP_SELL)
         { 
            if(OrderMagicNumber() != Magic) 
            {  
               //Comment(OrderMagicNumber());
               DeleteByMagic(OrderMagicNumber());
            }          
         }
   }
  } 
  //+---------------------------------------------------------------------------------------------------------------------------------------------------------------------+ 
 void DeleteByMagic(int Magic2)
  {
//--- 
  
   for(int i = OrdersTotal()-1;i>=0;i--)
   {
        ticket=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
        if(OrderType() != OP_BUY && OrderType() != OP_SELL)
         {  
           if(OrderMagicNumber() == Magic2)
           {
               ticket=OrderDelete(OrderTicket(),clrNONE);
           }          
         }
   }
  }  
  //+---------------------------------------------------------------------------------------------------------------------------------------------------------------------+ 
  void ChkOrderBuy(double EntryPrice)
  {
//---
   
   PriceFrom = EntryPrice - PriceRange*Point;
   PriceTo = EntryPrice + PriceRange*Point;
   //Comment("BID: "+Bid+" From: "+PriceFrom+" To: "+PriceTo);

   BuyCon3 = True;
         for(int i = OrdersTotal()-1;i>=0;i--)
         {
            if(OrderType() == OP_BUY)
            {
               ticket=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
               if(PriceFrom < OrderOpenPrice() && PriceTo > OrderOpenPrice())
               {  
                  BuyCon3 = False;
                  //Comment(PriceFrom +" : "+EntryPrice+" : "+ PriceTo+" : "+BuyCon3);
                  break;
               }else{
                  BuyCon3 = True;
                  //Comment(PriceFrom +" : "+EntryPrice+" : "+ PriceTo+" : "+BuyCon3);  
               }
            }
         }
   }

 //+---------------------------------------------------------------------------------------------------------------------------------------------------------------------+
   void ChkOrderSell(double EntryPrice)
  {
//---
   PriceFrom = EntryPrice - PriceRange*Point;
   PriceTo = EntryPrice + PriceRange*Point;
   //Comment("BID: "+Bid+" From: "+PriceFrom+" To: "+PriceTo);
    BuyCon3 = True;
         for(int i = OrdersTotal()-1;i>=0;i--)
         {
            if(OrderType() == OP_SELL)
            {
               ticket=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
               if(PriceFrom < OrderOpenPrice() && PriceTo > OrderOpenPrice())
               {  
                  BuyCon3 = False;
                  //Comment(PriceFrom +" : "+EntryPrice+" : "+ PriceTo+" : "+BuyCon3);
                  break;
               }else{
                  BuyCon3 = True;
                  //Comment(PriceFrom +" : "+EntryPrice+" : "+ PriceTo+" : "+BuyCon3);
                  
               }
            }
   } 

  }
 //+---------------------------------------------------------------------------------------------------------------------------------------------------------------------+
 void TraillingStop()
  {
//---
   double TP1;
   double CurrentPoint;
   
      for(int i = OrdersTotal()-1;i>=0;i--)
      {
         ticket=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
        // Comment(OrderProfit()+" / "+OrderStopLoss()+" / "+OrderOpenPrice()); 
 //        if(OrderType() == OP_BUY && OrderProfit() > 0 && OrderStopLoss()< OrderOpenPrice())
 //        {  
         
 //           CurrentPoint = ((Bid - OrderOpenPrice())* 1/Point);
 //           TP1=((OrderTakeProfit() - OrderOpenPrice())*1/Point)/Reward; 
            //Comment("Current Point : "+CurrentPoint + " TP : "+TP1); 
 //           if(CurrentPoint >= TP1)
 //           {  
 //            ticket=OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+10*Point,OrderTakeProfit(),0,clrNONE); 
 //            return;
 //           }
        
 //        }
         if(OrderType() == OP_SELL && OrderProfit() > 0 && OrderStopLoss()> OrderOpenPrice())
         {  
         
            CurrentPoint = (OrderOpenPrice()-Ask)*1/Point;
            TP1=((OrderOpenPrice()- OrderTakeProfit())*1/Point)/Reward;
            
            //Comment(CurrentPoint+" / "+TP1);
        
            if(CurrentPoint >= TP1)
            {
            ticket=OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-10*Point,OrderTakeProfit(),0,clrNONE);   
            return;
            }
         }
      }
  }