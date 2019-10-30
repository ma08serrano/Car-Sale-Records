000101181115     H BNDDIR('LRNGSRV') DFTACTGRP(*no) ACTGRP(*caller)
000102181115     H BNDDIR('EZISERVICE')
000103181115
000104181127     FCAR_SALES O  A E             DISK    RENAME(CAR_SALES:CAR_SALESr)
000105181115      /INCLUDE LRNGSOURCE,LRNGCOMMON
000106181115      /INCLUDE QRPGLESRC,STDINCLUDE
000107181115      /INCLUDE QRPGLESRC,EZISERVICE
000108181115
000109181129      * Define an EZI quick panel named MyTable
000110181115
000111181115      * Define EZI quick panels
000112181115
000113181129     D MyTable         Ds                  LikeDS(EZI_QPanel)  Inz(*LikeDS)
000114181115
000119181115      * Define the elements to be put onto Panel 1
000120181115
000121181202     D IdNumber        Ds                  LikeDS(EZI_TextBox)   Inz(*LikeDS)     Output label
000124181202     D CompanyName     Ds                  LikeDS(EZI_TextBox)   Inz(*LikeDS)
000126181115     D Calendar        DS                  LikeDS(EZI_Datetime)  Inz(*LikeDs)
000128181115     D ActualForecast  DS                  LikeDS(EZI_TextBox)   Inz(*LikeDs)
000129181115     D PrevForecast    DS                  LikeDS(EZI_TextBox)   Inz(*LikeDs)
000130181115     D CurrentSales    DS                  LikeDS(EZI_TextBox)   Inz(*LikeDs)
000131181115
000132181115      * Other local RPG variables
000133181115
000134181115     D MainLoopCount   s             10I00 Inz(0)
000137181115     D CalendarVal     s            256A   Varying
000142181115      * Declare a standard LongRange form view handler parameter list
000143181115
000144181127      /INCLUDE QRPGLESRC,STDPARAM
000145181115
000146181115      * Program mainline
000147181115
000148181115      /free
000149181115
000150181115        // Create the form view, then loop until this program should not handle the requests
000151181115
000152181115        Exsr Create_FORMVIEW;
000153181115        DoU (RequestPROGRAM <> ProgramINFO.Name);
000154181127          MainLoopCount += 1;
000155181115
000156181127          Exsr Handle_RequestACTION;   // Handle the user's requested action  (not used)
000157181127          // Send and receive the formview
000158181115
000159181127          LRNG_SendReceive((MainLoopCount > 1):RequestPROGRAM:RequestACTION);
000160181115        EndDo;
000161181115
000162181115        // Finished, so return control to driver.
000163181115
000164181115        *InLR = True;
000165181115        Return;
000166181115
000167181127        // ---------------------------------------------------------------------
000168181127        // Handle the user's request which is in variable RequestACTION
000169181127        // ---------------------------------------------------------------------
000170181115
000171181127        Begsr Handle_RequestACTION;
000172181115
000173181127        // Handle the various requested actions (aka: events) from the mobile device
000174181115
000175181127        Select;
000177181127          // Handle the requested action 'WRITE'
000179181127          When (RequestACTION = 'WRITE');
000182181127            CalendarVal    = EZI_QPanel_GetItemValue(Calendar);
000183181127
000184181202            CARID     = %DEC(EZI_QPanel_GetItemValue(IdNumber):9:0);
000187181127            COMPANY        = EZI_QPanel_GetItemValue(CompanyName);
000188181127            DATE           = %Date(CalendarVal:*iso0);
000190181127            ACTUA00001     = %DEC(EZI_QPanel_GetItemValue(ActualForecast):2:0);
000191181127            PREV_00001     = %DEC(EZI_QPanel_GetItemValue(PrevForecast):2:0);
000192181127            CURR_00001     = %DEC(EZI_QPanel_GetItemValue(CurrentSales):2:0);
000193181127
000194181127            Write CAR_SALESR;
000195181127
000196181203            EZI_OK_MessageBox('Success'
000197181203                        : 'New Record has been added');
000198181203
000199181203            EZI_QPanel_SetItemValue(IdNumber:'');
000200181203            EZI_QPanel_SetItemValue(CompanyName:'');
000201181203            EZI_QPanel_SetItemValue(Calendar:'');
000202181203            EZI_QPanel_SetItemValue(ActualForecast:'');
000203181203            EZI_QPanel_SetItemValue(PrevForecast:'');
000204181203            EZI_QPanel_SetItemValue(CurrentSales:'');
000205181203
000206181127          // Handle the requested action 'CLEAR'
000207181127          When (RequestACTION = 'CLEAR');
000208181202            EZI_QPanel_SetItemValue(IdNumber:'');
000209181127            EZI_QPanel_SetItemValue(CompanyName:'');
000210181127            EZI_QPanel_SetItemValue(Calendar:'');
000212181127            EZI_QPanel_SetItemValue(ActualForecast:'');
000213181127            EZI_QPanel_SetItemValue(PrevForecast:'');
000214181127            EZI_QPanel_SetItemValue(CurrentSales:'');
000216181127          Endsl;
000218181127        EndSr;
000219181115
000221181127        // ---------------------------------------------------------------------
000222181127        // Create the form view
000223181127        // ---------------------------------------------------------------------
000224181115
000225181127        Begsr Create_FORMVIEW;
000227181203          MyTable.Title           = 'New Car Record';
000229181129          MyTable.OverallStyle    = 11;  // Good for small screen devices
000230181129          MyTable.BorderThickness = 0;   // No border
000231181115
000232181203          MyTable.ParentGRow = 2;
000233181129          MyTable.ParentGCol = 1;
000234181127
000235181202          IdNumber.Label = 'Car ID';
000236181203          IdNumber.InitialValue = '';
000237181202          EZI_QPanel_DefineItem( MyTable : IdNumber );
000238181202
000239181127          CompanyName.Label = 'Car Model';
000240181129          EZI_QPanel_DefineItem( MyTable : CompanyName );
000241181115
000251181127          Calendar.Label = 'Date';
000252181129          EZI_QPanel_DefineItem( MyTable : Calendar );
000253181115
000269181127          ActualForecast.Label = 'Actual Forecast';
000272181129          EZI_QPanel_DefineItem( MyTable : ActualForecast );
000275181115
000276181202          PrevForecast.Label = 'Previous Sales';
000279181129          EZI_QPanel_DefineItem( MyTable : PrevForecast );
000280181115
000302181127          CurrentSales.Label = 'Current Sales';
000306181129          EZI_QPanel_DefineItem( MyTable : CurrentSales );
000307181129
000308181129          // set the background color
000309181129
000310181129          LRNG_SetProperty('/Form.BackColor' : '&544d5b');
000311181115
000312181129          EZI_QPanel_Define( MyTable );
000315181127
000316181127        EndSr;
000317181127
000318181127        /end-free
