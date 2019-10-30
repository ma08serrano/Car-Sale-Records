000100181202     H BNDDIR('LRNGSRV') DFTACTGRP(*no) ACTGRP(*caller)
000101181202     H BNDDIR('EZISERVICE')
000102181202     F* file spec required here for file to be updated
000103181202     FCAR_SALES UF   E           K DISK    Rename (CAR_SALES:CARSALESr)
000104181202      * ----------------------------------------------------------------------------------------
000105181202      // Locally scoped field definitions
000106181202      /INCLUDE LRNGSOURCE,LRNGCOMMON
000107181202      * Standard demonstration definitions and prototypes
000108181202      /INCLUDE SOURCEDEMO,DEMOCOMMON
000109181202      * Program uses "EZI" building block services - see your version of library LRNG_PROJ
000110181202      /INCLUDE QRPGLESRC,EZISERVICE
000111181202      * Work fields
000112181202     D                 DS
000113181202     D CSNumber        S              9A   Inz('') Varying
000115181202     D CSNumberN       S              9  0 Inz(0)
000123181202     D                 DS
000124181202     D MainLoopCount                 10I00  Inz(0)
000128181202
000129181202     D UseEZIOverallStyle...
000130181202     D                               10I00  Inz(0)
000131181202     D CombinationStyle...
000132181202     D                               10I00  Inz(0)
000133181202     D UseEZIBorderThickness...
000134181202     D                               10I00  Inz(-1)
000144181202      * The EZI Quick Panel ...
000145181202     D Panel           Ds                  LikeDS(EZI_QPanel)      Inz(*LikeDS)
000146181202      * The Panel elements
000147181202     D IdNumberT       Ds                  LikeDS(EZI_Label)       Inz(*LikeDS)
000148181202     D CompanyT        Ds                  LikeDS(EZI_TextBox)     Inz(*LikeDS)
000149181202     D DateT           Ds                  LikeDS(EZI_Label)       Inz(*LikeDs)
000150181202     D ActualSalesT    Ds                  LikeDS(EZI_TextBox)     Inz(*LikeDS)
000151181202     D PrevForecastT   Ds                  LikeDS(EZI_TextBox)     Inz(*LikeDS)
000152181202     D CurrForecastT   Ds                  LikeDS(EZI_TextBox)     Inz(*LikeDS)
000153181202
000154181202      * Standard form view handler parameter list declaration
000155181202      /INCLUDE SOURCEDEMO,STDPARAMS
000156181202      * Use free format coding style
000157181202      /free
000158181202        // Start with different style examples
000159181202        If ( EZI_IsLargeDevice(SystemINFO) );
000160181202          CombinationStyle = 0;
000161181202        Else;
000162181202          CombinationStyle = 6;
000163181202        EndIf;
000164181202
000165181202        ///O// Loop until this program should not handle the user's requests
000166181202        DoU (RequestPROGRAM <> ProgramINFO.Name);
000167181202
000168181202          // Update the switch so that the entire screen is redisplayed, not
000169181202          // just the changes
000170181202          MainLoopCount += 1;
000171181202
000172181202          If (MainLoopCount = 1);
000173181202            Exsr GetData;
000174181202            Exsr Define_EZI_Panel;
000175181202          Endif;
000176181202
000177181202          If ( EZI_HandleRequestACTION( RequestACTION:RequestPROGRAM
000178181202                               : SavedSTATE:SystemINFO:ProgramINFO) = False );
000179181202            // Handle the user's requested action .......
000180181202
000181181202            Select;
000182181202              // -----------------------------------------------------------------
000183181202              // When the user wants to swap styles do that and rebuild the screen
000184181202              // -----------------------------------------------------------------
000185181202              When ( RequestACTION = 'CHANGE_STYLE' );
000186181202                Exsr Define_EZI_Panel;
000187181202                Exsr Load_EZI_Panel_Content;
000188181202                MainLoopCount = 1;
000189181202
000190181202              When ( RequestACTION = 'BACK' );
000191181202                RequestACTION = 'DEFAULT';
000192181202                // Set the name of the program to call for Details Form View
000193181202                RequestPROGRAM = 'UPDTETABLE';
000194181202                // Call the LongRange API SwitchToFormView
000195181202                  LRNG_SwitchToFormView('FormUpdateTable');
000196181202                  *InLR = True;
000197181202                  Return;
000198181202
000199181202              When ( RequestACTION = 'SAVE');
000201181202                COMPANY     = EZI_QPanel_GetItemValue(CompanyT);
000202181202                ACTUA00001  = %dec(EZI_QPanel_GetItemValue(ActualSalesT):2:0);
000203181202                PREV_00001  = %dec(EZI_QPanel_GetItemValue(PrevForecastT):2:0);
000204181202                CURR_00001  = %dec(EZI_QPanel_GetItemValue(CurrForecastT):2:0);
000205181202
000210181202                  Update CARSALESr;
000211181202                  Exsr GetData;
000212181203
000213181203                EZI_OK_MessageBox('Success'
000214181203                        : 'New Record has been updated');
000231181202
000232181202              // -----------------------------------------------------------------
000233181202              // Otherwise load new EZI panel content
000234181202              // -----------------------------------------------------------------
000235181202
000236181202              Other;
000237181202                Exsr GetData;
000238181202                Exsr Load_EZI_Panel_Content;
000239181202            EndSl;
000240181202          Endif;
000241181202
000242181202          // Send and receive the screen - no DDS are used here - but
000243181202          // you can use QPanels on DDS defined formviews as well.
000244181202          LRNG_SendReceive((MainLoopCount > 1):RequestPROGRAM:RequestACTION);
000245181202
000246181202          // Loop to process next request (or not)
000247181202        EndDo;
000248181202
000249181202        // Finished. Return control to driver.
000250181202        *InLR = True;
000251181202        Return;
000252181202        ///E/// ----------------------------------------------------------------------
000253181202        ///E/// Load the EZI Quick panel content
000254181202        ///E/// ----------------------------------------------------------------------
000255181202        Begsr Load_EZI_Panel_Content;
000256181202          EZI_QPanel_SetItemValue(IdNumberT    : %char(CARID));
000257181202          EZI_QPanel_SetItemValue(CompanyT     : COMPANY);
000258181202          EZI_QPanel_SetItemValue(DateT        : %char(DATE));
000259181202          EZI_QPanel_SetItemValue(ActualSalesT : %char(ACTUA00001));
000260181202          EZI_QPanel_SetItemValue(PrevForecastT: %char(PREV_00001));
000261181202          EZI_QPanel_SetItemValue(CurrForecastT: %char(CURR_00001));
000262181202        Endsr;
000263181202
000264181202        ///E/// ----------------------------------------------------------------------
000265181202        ///E/// Define the EZI Quick panel
000266181202        ///E/// ----------------------------------------------------------------------
000267181202        Begsr Define_EZI_Panel;
000268181202          // Change styles
000269181202          Exsr ChangeStyle;
000270181202
000271181202          // Set up the high level form grid layout
000272181202          Panel.ParentGRow = 1;  // Panel 1 at 1,1
000273181202          Panel.ParentGCol = 1;
000274181202
000275181202          // -----------------------------
000276181202          // Define all the Panel elements
000277181202          // -----------------------------
000278181202          Panel.Title            =  'Car Details';
000279181202          Panel.OverallStyle     =  UseEZIOverallStyle;
000280181202          Panel.BorderThickness  =  UseEZIBorderThickness;
000281181202
000282181202          // You can control the default email and SMS subject and recipient
000283181202
000284181202          // Define the Car Id
000285181202          IdNumberT.Label = 'Car ID';
000286181202          EZI_QPanel_DefineItem( Panel : IdNumberT );
000287181202
000288181202          // Define the Company
000289181202          CompanyT.Label = 'Car Model';
000290181202          EZI_QPanel_DefineItem( Panel : CompanyT );
000291181202
000292181202          // Define the Date
000293181202          DateT.Label = 'Date';
000294181202          EZI_QPanel_DefineItem( Panel : DateT );
000295181202
000296181202          // Define the Actual Forecast
000297181202          ActualSalesT.Label = 'Actual Forecast';
000298181202          EZI_QPanel_DefineItem( Panel :  ActualSalesT );
000299181202
000300181202          // Define the Previous Forecast
000301181202          PrevForecastT.Label = 'Previous Sales';
000302181202          EZI_QPanel_DefineItem( Panel : PrevForecastT );
000303181202
000304181202          // Define the Current Forecast
000305181202          CurrForecastT.Label = 'Current Sales';
000306181202          EZI_QPanel_DefineItem( Panel : CurrForecastT );
000307181202
000308181202          // set the background color
000309181202          LRNG_SetProperty('/Form.BackColor' : '&544d5b');
000310181202
000311181202          // Now define the EZI Quick Panel
000312181202          EZI_QPanel_Define(Panel);
000313181202        EndSr;
000314181202          //O/// ----------------------------------------------------------------------------
000315181202          ///O/// Change the style of the panels. See Paneln.OverallStyle in Define_EZI_Panels
000316181202          //O/// ----------------------------------------------------------------------------
000317181202        Begsr ChangeStyle;
000318181202
000319181202          CombinationStyle += 1;
000320181202          If (CombinationStyle > 12);
000321181202            CombinationStyle = 1;
000322181202          Endif;
000323181202
000324181202          Select;
000325181202            when (CombinationStyle = 1);
000326181202              UseEZIOverallStyle = 1;
000327181202              UseEZIBorderThickness = -1;
000328181202            when (CombinationStyle = 2);
000329181202              UseEZIOverallStyle = 1;
000330181202              UseEZIBorderThickness = 0;
000331181202            when (CombinationStyle = 3);
000332181202               UseEZIOverallStyle = 2;
000333181202               UseEZIBorderThickness = -1;
000334181202            when (CombinationStyle = 4);
000335181202               UseEZIOverallStyle = 2;
000336181202               UseEZIBorderThickness = 0;
000337181202            when (CombinationStyle = 5);
000338181202               UseEZIOverallStyle = 3;
000339181202               UseEZIBorderThickness = -1;
000340181202            when (CombinationStyle = 6);
000341181202               UseEZIOverallStyle = 3;
000342181202               UseEZIBorderThickness = 0;
000343181202            when (CombinationStyle = 7);
000344181202               UseEZIOverallStyle = 11;
000345181202               UseEZIBorderThickness = -1;
000346181202            when (CombinationStyle = 8);
000347181202               UseEZIOverallStyle = 11;
000348181202               UseEZIBorderThickness = 0;
000349181202            when (CombinationStyle = 9);
000350181202               UseEZIOverallStyle = 12;
000351181202               UseEZIBorderThickness = -1;
000352181202            when (CombinationStyle = 10);
000353181202               UseEZIOverallStyle = 12;
000354181202               UseEZIBorderThickness = 0;
000355181202            when (CombinationStyle = 11);
000356181202               UseEZIOverallStyle = 13;
000357181202               UseEZIBorderThickness = -1;
000358181202            Other;
000359181202               UseEZIOverallStyle = 13;
000360181202               UseEZIBorderThickness = 0;
000361181202         EndSl;
000362181202
000363181202       Endsr;
000364181202
000365181202       // get car data
000366181202       Begsr GetData;
000367181202         CSNumber = SAVEDState.CurrentCONTACT;
000368181203         CSNumberN = %DEC((CSNumber):9:0);
000369181202
000370181202         Setll *start CAR_SALES;
000371181202         Read CAR_SALES;
000372181202         Dow (NOT %EOF);
000373181202           If (CSNumberN = CARID);
000374181202             leave;
000375181202           EndIf;
000376181202           Read CAR_SALES;
000377181202         EndDo;
000378181202       EndSr;
000379181202      /end-free
